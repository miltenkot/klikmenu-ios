import Foundation
import Testing
import KlikMenuCore

@Suite(.serialized)
struct APIClientTests {
    final class MockURLProtocol: URLProtocol, @unchecked Sendable {
        nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (Int, Data))?
        private static let lock = NSLock()

        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            do {
                Self.lock.lock()
                let currentHandler = Self.handler
                Self.lock.unlock()
                guard let currentHandler else {
                    throw URLError(.badServerResponse)
                }
                let result = try currentHandler(request)
                let url = request.url ?? LiveKlikMenuAPIClient.defaultBaseURL
                guard let response = HTTPURLResponse(
                    url: url,
                    statusCode: result.0,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                ) else {
                    throw URLError(.badServerResponse)
                }
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: result.1)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {}

        static func setHandler(
            _ handler: @escaping @Sendable (URLRequest) throws -> (Int, Data)
        ) {
            lock.lock()
            self.handler = handler
            lock.unlock()
        }
    }

    private func makeAPI() -> LiveKlikMenuAPIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return LiveKlikMenuAPIClient(
            baseURL: LiveKlikMenuAPIClient.defaultBaseURL,
            http: URLSessionHTTPClient(session: session)
        )
    }

    @Test func mapsNotFoundResponse() async {
        MockURLProtocol.setHandler { _ in
            (404, Data(#"{"error":{"code":"NOT_FOUND","message":"missing"}}"#.utf8))
        }
        let api = makeAPI()
        do {
            _ = try await api.fetchMenu(slug: "missing", locale: .pl)
            Issue.record("Expected not found")
        } catch let error as APIError {
            #expect(error == .notFound)
        } catch {
            Issue.record("Unexpected error \(error)")
        }
    }

    @Test func mapsTooManyRequests() async {
        let body = Data(#"{"error":{"code":"RATE_LIMIT","message":"Too many"}}"#.utf8)
        MockURLProtocol.setHandler { request in
            #expect(request.httpMethod == "POST")
            return (429, body)
        }
        let api = makeAPI()
        do {
            _ = try await api.submitFeedback(
                slug: "r",
                request: FeedbackRequest(waiterID: "w", rating: 5, comment: nil)
            )
            Issue.record("Expected 429")
        } catch let error as APIError {
            #expect(
                {
                    var copy = error.userFacingMessage
                    copy.locale = Locale(identifier: "pl")
                    return String(localized: copy)
                }()
                .localizedCaseInsensitiveContains("zbyt wiele")
            )
        } catch {
            Issue.record("Unexpected error \(error)")
        }
    }

    @Test func mapsServerError() async {
        MockURLProtocol.setHandler { _ in
            (500, Data(#"{"error":{"code":"INTERNAL","message":"boom"}}"#.utf8))
        }
        do {
            _ = try await makeAPI().submitFeedback(
                slug: "r",
                request: FeedbackRequest(waiterID: "w", rating: 3, comment: "ok")
            )
            Issue.record("Expected server error")
        } catch let error as APIError {
            guard case .http(let status, _, _) = error else {
                Issue.record("Expected http error")
                return
            }
            #expect(status == 500)
            #expect(
                {
                    var copy = error.userFacingMessage
                    copy.locale = Locale(identifier: "pl")
                    return String(localized: copy)
                }()
                .localizedCaseInsensitiveContains("serwer")
            )
        } catch {
            Issue.record("Unexpected error \(error)")
        }
    }

    @Test func decodesFeedbackConfig() async throws {
        let body = Data(
            #"""
            {"data":{"enabled":true,"restaurantName":"Bistro","baseLocale":"pl","availableLocales":["pl","en"],"waiters":[{"id":"w","name":"Anna","photoUrl":null}]}}
            """#.utf8
        )
        MockURLProtocol.setHandler { _ in (200, body) }
        let config = try await makeAPI().fetchFeedbackConfig(slug: "bistro")
        #expect(config.enabled)
        #expect(config.baseLocale == .pl)
        #expect(config.availableLocales == [.pl, .en])
        #expect(config.waiters.count == 1)
        #expect(config.waiters[0].name == "Anna")
        #expect(config.isFeedbackAvailable)
    }

    @Test func decodesDisabledFeedbackConfigWithEmptyWaiters() async throws {
        let body = Data(
            #"""
            {"data":{"enabled":false,"restaurantName":"Bistro","baseLocale":"pl","availableLocales":["pl"],"waiters":[]}}
            """#.utf8
        )
        MockURLProtocol.setHandler { _ in (200, body) }
        let config = try await makeAPI().fetchFeedbackConfig(slug: "bistro")
        #expect(config.enabled == false)
        #expect(config.waiters.isEmpty)
        #expect(config.isFeedbackAvailable == false)
    }

    @Test func encodesFeedbackSubmitRequestBody() async throws {
        MockURLProtocol.setHandler { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path.hasSuffix("/feedback") == true)
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

            let body: Data
            if let httpBody = request.httpBody {
                body = httpBody
            } else if let stream = request.httpBodyStream {
                stream.open()
                defer { stream.close() }
                var collected = Data()
                let bufferSize = 1024
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { buffer.deallocate() }
                while stream.hasBytesAvailable {
                    let read = stream.read(buffer, maxLength: bufferSize)
                    guard read > 0 else { break }
                    collected.append(buffer, count: read)
                }
                body = collected
            } else {
                Issue.record("Missing request body")
                return (500, Data())
            }

            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            #expect(json?["waiterId"] as? String == "waiter-1")
            #expect(json?["rating"] as? Int == 4)
            #expect(json?["comment"] as? String == "Great service")
            #expect(json?["website"] as? String == "")
            return (202, Data(#"{"accepted":true}"#.utf8))
        }

        let response = try await makeAPI().submitFeedback(
            slug: "bistro-klik",
            request: FeedbackRequest(waiterID: "waiter-1", rating: 4, comment: "Great service")
        )
        #expect(response.accepted == true)
    }
}
