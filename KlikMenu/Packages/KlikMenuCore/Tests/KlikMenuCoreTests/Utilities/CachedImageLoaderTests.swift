import Foundation
import Testing
import KlikMenuCore

@Suite(.serialized)
struct CachedImageLoaderTests {
    final class RequestCounter: @unchecked Sendable {
        private var count = 0
        private let lock = NSLock()

        func increment() {
            lock.lock()
            count += 1
            lock.unlock()
        }

        var value: Int {
            lock.lock()
            defer { lock.unlock() }
            return count
        }
    }

    final class RequestLog: @unchecked Sendable {
        private var urls: [URL] = []
        private let lock = NSLock()

        func append(_ url: URL) {
            lock.lock()
            urls.append(url)
            lock.unlock()
        }

        var value: [URL] {
            lock.lock()
            defer { lock.unlock() }
            return urls
        }
    }

    final class MockImageURLProtocol: URLProtocol, @unchecked Sendable {
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
                let url = request.url ?? URL(string: "https://cdn.example.test/image.png")!
                guard let response = HTTPURLResponse(
                    url: url,
                    statusCode: result.0,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "image/png"]
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

    private let samplePNGData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXcAAAAASUVORK5CYII=")!

    private func makeLoader() -> CachedImageLoader {
        let urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 0)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockImageURLProtocol.self]
        configuration.urlCache = urlCache
        configuration.requestCachePolicy = .useProtocolCachePolicy
        let session = URLSession(configuration: configuration)
        return CachedImageLoader(session: session, urlCache: urlCache)
    }

    @Test func firstRequestLoadsFromNetwork() async throws {
        let networkURL = URL(string: "https://cdn.example.test/first.png")!
        let networkRequestCount = RequestCounter()

        MockImageURLProtocol.setHandler { request in
            guard request.url == networkURL else {
                Issue.record("Unexpected URL \(request.url?.absoluteString ?? "nil")")
                return (404, Data())
            }
            networkRequestCount.increment()
            return (200, samplePNGData)
        }

        let loader = makeLoader()
        let data = try await loader.load(url: networkURL, cacheKey: "menu-items/2026-01-01/item-a.png")
        #expect(data == samplePNGData)
        #expect(networkRequestCount.value == 1)
    }

    @Test func secondRequestUsesCacheForSameKeyDespiteDifferentURL() async throws {
        let firstURL = URL(string: "https://cdn.example.test/first.png?sig=1")!
        let secondURL = URL(string: "https://cdn.example.test/first.png?sig=2")!
        let networkRequestCount = RequestCounter()

        MockImageURLProtocol.setHandler { request in
            guard request.url == firstURL || request.url == secondURL else {
                Issue.record("Unexpected URL \(request.url?.absoluteString ?? "nil")")
                return (404, Data())
            }
            networkRequestCount.increment()
            return (200, samplePNGData)
        }

        let loader = makeLoader()
        let cacheKey = "menu-items/2026-01-01/shared-item.png"

        let firstLoad = try await loader.load(url: firstURL, cacheKey: cacheKey)
        let secondLoad = try await loader.load(url: secondURL, cacheKey: cacheKey)

        #expect(firstLoad == samplePNGData)
        #expect(secondLoad == samplePNGData)
        #expect(networkRequestCount.value == 1)
    }

    @Test func differentImageKeysAreCachedSeparately() async throws {
        let urlA = URL(string: "https://cdn.example.test/a.png")!
        let urlB = URL(string: "https://cdn.example.test/b.png")!
        let requestedURLs = RequestLog()

        MockImageURLProtocol.setHandler { request in
            guard let url = request.url else {
                return (404, Data())
            }
            requestedURLs.append(url)
            return (200, samplePNGData)
        }

        let loader = makeLoader()
        _ = try await loader.load(url: urlA, cacheKey: "menu-items/2026-01-01/item-a.png")
        _ = try await loader.load(url: urlB, cacheKey: "menu-items/2026-01-01/item-b.png")

        #expect(requestedURLs.value == [urlA, urlB])
    }

    @Test func errorResponseIsNotCached() async throws {
        let networkURL = URL(string: "https://cdn.example.test/missing.png")!
        let networkRequestCount = RequestCounter()

        MockImageURLProtocol.setHandler { request in
            guard request.url == networkURL else {
                return (404, Data())
            }
            networkRequestCount.increment()
            return (404, Data("not found".utf8))
        }

        let loader = makeLoader()
        let cacheKey = "menu-items/2026-01-01/missing.png"

        await #expect(throws: ImageLoadError.invalidResponse) {
            try await loader.load(url: networkURL, cacheKey: cacheKey)
        }

        await #expect(throws: ImageLoadError.invalidResponse) {
            try await loader.load(url: networkURL, cacheKey: cacheKey)
        }

        #expect(networkRequestCount.value == 2)
    }
}
