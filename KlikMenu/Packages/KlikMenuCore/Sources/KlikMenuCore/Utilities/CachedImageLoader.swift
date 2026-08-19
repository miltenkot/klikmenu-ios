import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum ImageLoadError: Error, Equatable {
    case invalidResponse
}

public struct CachedImageLoader: Sendable {
    public static let shared = CachedImageLoader()

    private let session: URLSession
    private let urlCache: URLCache

    public init(
        session: URLSession = ImageURLCacheConfiguration.imageSession,
        urlCache: URLCache = ImageURLCacheConfiguration.urlCache
    ) {
        self.session = session
        self.urlCache = urlCache
    }

    public func load(url: URL, cacheKey: String) async throws -> Data {
        let cacheRequest = URLRequest(
            url: Self.cacheStorageURL(for: cacheKey),
            cachePolicy: .returnCacheDataElseLoad
        )

        if let cachedResponse = urlCache.cachedResponse(for: cacheRequest),
           isValidImageData(cachedResponse.data) {
            return cachedResponse.data
        }

        let networkRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        let (data, response) = try await session.data(for: networkRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              isValidImageData(data) else {
            throw ImageLoadError.invalidResponse
        }

        let storageResponse = HTTPURLResponse(
            url: cacheRequest.url!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "image/png",
            ]
        )!

        urlCache.storeCachedResponse(
            CachedURLResponse(response: storageResponse, data: data),
            for: cacheRequest
        )

        return data
    }

    static func cacheStorageURL(for cacheKey: String) -> URL {
        let encoded = cacheKey.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? cacheKey
        return URL(string: "https://image-cache.klikmenu.app/\(encoded)")!
    }

    private func isValidImageData(_ data: Data) -> Bool {
        guard !data.isEmpty else { return false }
        #if canImport(UIKit)
        return UIImage(data: data) != nil
        #elseif canImport(AppKit)
        return NSImage(data: data) != nil
        #else
        return true
        #endif
    }
}
