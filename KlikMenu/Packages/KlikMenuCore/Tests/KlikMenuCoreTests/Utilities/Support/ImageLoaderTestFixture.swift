import Foundation
import Testing
@testable import KlikMenuCore

struct ImageLoaderTestFixture {
    let cache: URLCache
    let session: URLSession
    let loader: CachedImageLoader
    let url: URL
    let cacheRequest: URLRequest
    let png: Data
    let key = "menu/żurek photo.png"

    init() throws {
        url = try #require(URL(string: "https://images.example.test/photo.png"))
        png = try #require(Data(base64Encoded:
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXcAAAAASUVORK5CYII="
        ))
        cache = URLCache(memoryCapacity: 1024 * 1024, diskCapacity: 0)
        cacheRequest = URLRequest(url: CachedImageLoader.cacheStorageURL(for: key))
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageLoaderURLProtocol.self]
        // Only the loader's explicit cache is involved in these tests.
        configuration.urlCache = nil
        session = URLSession(configuration: configuration)
        loader = CachedImageLoader(session: session, urlCache: cache)
    }

    func response(status: Int = 200, headers: [String: String]? = nil) throws -> HTTPURLResponse {
        try #require(HTTPURLResponse(
            url: url, statusCode: status, httpVersion: nil, headerFields: headers
        ))
    }

    func cleanUp() {
        session.invalidateAndCancel()
        cache.removeAllCachedResponses()
        ImageLoaderURLProtocol.setHandler(nil)
    }
}
