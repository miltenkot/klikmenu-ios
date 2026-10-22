import Foundation
import Testing
import KlikMenuCore

@Suite(.serialized)
struct MenuLocaleAPIClientTests {
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
                guard let currentHandler else { throw URLError(.badServerResponse) }
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

        static func setHandler(_ handler: @escaping @Sendable (URLRequest) throws -> (Int, Data)) {
            lock.lock()
            self.handler = handler
            lock.unlock()
        }
    }

    private func makeAPI() -> LiveKlikMenuAPIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return LiveKlikMenuAPIClient(
            baseURL: LiveKlikMenuAPIClient.defaultBaseURL,
            http: URLSessionHTTPClient(session: URLSession(configuration: config))
        )
    }

    private var menuJSON: Data {
        Data(
            """
            {
              "data": {
                "id": "r",
                "name": "Bistro",
                "slug": "bistro-klik",
                "description": null,
                "address": null,
                "phone": null,
                "currency": "PLN",
                "isPublished": true,
                "feedbackEnabled": false,
                "createdAt": "2026-01-01T00:00:00Z",
                "updatedAt": "2026-01-01T00:00:00Z",
                "heroImageUrl": null,
                "requestedLocale": "en",
                "resolvedLocale": "en",
                "baseLocale": "pl",
                "availableLocales": ["pl", "en"],
                "supportedLocales": ["pl", "en", "de", "uk", "cs", "sk"],
                "categories": []
              }
            }
            """.utf8
        )
    }

    @Test func menuRequestContainsLocaleQueryAndEncodedSlug() async throws {
        MockURLProtocol.setHandler { [menuJSON] request in
            let url = try #require(request.url)
            let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
            #expect(components.path == "/api/v1/public/restaurants/bistro-klik/menu")
            #expect(components.queryItems == [URLQueryItem(name: "locale", value: "en")])
            return (200, menuJSON)
        }

        let menu = try await makeAPI().fetchMenu(slug: "bistro-klik", locale: .en)
        #expect(menu.slug == "bistro-klik")
        #expect(menu.resolvedLocale == .en)
        #expect(menu.requestedLocale == .en)
        #expect(menu.baseLocale == .pl)
    }
}
