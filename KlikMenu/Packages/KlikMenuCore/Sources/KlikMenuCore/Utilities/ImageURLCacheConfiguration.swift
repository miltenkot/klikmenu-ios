import Foundation

public enum ImageURLCacheConfiguration {
    public static let memoryCapacity = 50 * 1024 * 1024
    public static let diskCapacity = 200 * 1024 * 1024

    private static let lock = NSLock()
    nonisolated(unsafe) private static var isConfigured = false

    public static let urlCache = URLCache(
        memoryCapacity: memoryCapacity,
        diskCapacity: diskCapacity,
        diskPath: "KlikMenuImageCache"
    )

    public static let imageSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }()

    public static func configureIfNeeded() {
        lock.lock()
        defer { lock.unlock() }
        guard !isConfigured else { return }
        URLCache.shared = urlCache
        isConfigured = true
    }
}
