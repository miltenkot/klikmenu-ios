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
            _ = try await api.fetchMenu(slug: "missing")
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
            #expect(error.userFacingMessage.localizedCaseInsensitiveContains("zbyt wiele"))
        } catch {
            Issue.record("Unexpected error \(error)")
        }
    }

    @Test func decodesFeedbackConfig() async throws {
        let body = Data(
            #"{"data":{"enabled":true,"restaurantName":"Bistro","waiters":[{"id":"w","name":"Anna","photoUrl":null}]}}"#
                .utf8
        )
        MockURLProtocol.setHandler { _ in (200, body) }
        let config = try await makeAPI().fetchFeedbackConfig(slug: "bistro")
        #expect(config.enabled)
        #expect(config.waiters.count == 1)
        #expect(config.waiters[0].name == "Anna")
    }
}
