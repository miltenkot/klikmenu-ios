import Foundation

/// Central API environment configuration for KlikMenu clients.
public enum KlikMenuAPIConfiguration: Sendable {
    public static let productionBaseURL: URL = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.klikmenu.pl"
        return components.url ?? URL(fileURLWithPath: "/api-klikmenu-pl-missing")
    }()

    public static let developmentBaseURL: URL = {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "192.168.100.18"
        components.port = 3000
        return components.url ?? URL(fileURLWithPath: "/api-klikmenu-dev-missing")
    }()

    public static var baseURL: URL {
        #if DEBUG
        developmentBaseURL
        #else
        productionBaseURL
        #endif
    }
}
