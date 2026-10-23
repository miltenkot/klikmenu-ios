import Foundation
import Testing
@testable import KlikMenuCore

@Suite(.serialized)
struct CachedImageLoaderValidationTests {
    @Test(arguments: [Data(), Data("not an image".utf8)])
    func invalidImageIsRejectedWithoutCachingAndRetrySucceeds(data: Data) async throws {
        let fixture = try ImageLoaderTestFixture()
        defer { fixture.cleanUp() }
        let response = try fixture.response()
        ImageLoaderURLProtocol.setHandler { _ in (response, data) }

        await #expect(throws: ImageLoadError.invalidResponse) {
            try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
        }
        #expect(fixture.cache.cachedResponse(for: fixture.cacheRequest) == nil)

        ImageLoaderURLProtocol.setHandler { _ in (response, fixture.png) }
        let recovered = try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
        #expect(recovered == fixture.png)
        #expect(fixture.cache.cachedResponse(for: fixture.cacheRequest)?.data == fixture.png)
    }

    @Test(arguments: [Data(), Data("corrupted cache".utf8)])
    func invalidCachedImageIsReplacedAndReused(data: Data) async throws {
        let fixture = try ImageLoaderTestFixture()
        defer { fixture.cleanUp() }
        let response = try fixture.response()
        fixture.cache.storeCachedResponse(
            CachedURLResponse(response: response, data: data),
            for: fixture.cacheRequest
        )
        #expect(fixture.cache.cachedResponse(for: fixture.cacheRequest)?.data == data)
        ImageLoaderURLProtocol.setHandler { _ in (response, fixture.png) }

        let loaded = try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
        #expect(loaded == fixture.png)
        #expect(fixture.cache.cachedResponse(for: fixture.cacheRequest)?.data == fixture.png)

        ImageLoaderURLProtocol.setHandler { _ in
            Issue.record("A repaired cache entry should avoid another network request")
            throw URLError(.notConnectedToInternet)
        }
        let cached = try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
        #expect(cached == fixture.png)
    }

    @Test func nonHTTPResponseIsRejectedWithoutCaching() async throws {
        let fixture = try ImageLoaderTestFixture()
        defer { fixture.cleanUp() }
        let response = URLResponse(
            url: fixture.url, mimeType: "image/png",
            expectedContentLength: fixture.png.count, textEncodingName: nil
        )
        ImageLoaderURLProtocol.setHandler { _ in (response, fixture.png) }

        await #expect(throws: ImageLoadError.invalidResponse) {
            try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
        }
        #expect(fixture.cache.cachedResponse(for: fixture.cacheRequest) == nil)
    }

    @Test(arguments: [199, 300, 404, 500])
    func nonSuccessStatusIsRejectedEvenWithValidImage(status: Int) async throws {
        let fixture = try ImageLoaderTestFixture()
        defer { fixture.cleanUp() }
        let response = try fixture.response(status: status)
        ImageLoaderURLProtocol.setHandler { _ in (response, fixture.png) }

        await #expect(throws: ImageLoadError.invalidResponse) {
            try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
        }
        #expect(fixture.cache.cachedResponse(for: fixture.cacheRequest) == nil)
    }

    @Test(arguments: [URLError.Code.timedOut, .notConnectedToInternet, .cancelled])
    func transportFailureIsPropagatedAndRetrySucceeds(code: URLError.Code) async throws {
        let fixture = try ImageLoaderTestFixture()
        defer { fixture.cleanUp() }
        ImageLoaderURLProtocol.setHandler { _ in throw URLError(code) }

        do {
            _ = try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
            Issue.record("Expected a transport error")
        } catch {
            let urlError = try #require(error as? URLError)
            #expect(urlError.code == code)
        }
        #expect(fixture.cache.cachedResponse(for: fixture.cacheRequest) == nil)

        let response = try fixture.response()
        ImageLoaderURLProtocol.setHandler { _ in (response, fixture.png) }
        let recovered = try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)
        #expect(recovered == fixture.png)
    }

    @Test(arguments: [200, 299])
    func successfulResponseWithoutContentTypeCachesWithPNGDefault(status: Int) async throws {
        let fixture = try ImageLoaderTestFixture()
        defer { fixture.cleanUp() }
        let response = try fixture.response(status: status)
        ImageLoaderURLProtocol.setHandler { _ in (response, fixture.png) }

        let loaded = try await fixture.loader.load(url: fixture.url, cacheKey: fixture.key)

        #expect(loaded == fixture.png)
        let cached = try #require(fixture.cache.cachedResponse(for: fixture.cacheRequest))
        let cachedResponse = try #require(cached.response as? HTTPURLResponse)
        #expect(cachedResponse.value(forHTTPHeaderField: "Content-Type") == "image/png")
        #expect(cached.data == fixture.png)
    }
}
