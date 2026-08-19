import Foundation

public enum RestaurantMenuURLSecurityPolicy: Sendable {
  public enum EndpointKind: Sendable, Equatable {
    case production
    case localDevelopment
  }

  public enum ValidationOutcome: Sendable, Equatable {
    case allowed(EndpointKind)
    case rejected(reason: String)
  }

  public static var allowsLocalDevelopmentHTTP: Bool {
    #if DEBUG
    true
    #else
    false
    #endif
  }

  public static func validate(
    components: URLComponents,
    allowsLocalDevelopmentHTTP: Bool = Self.allowsLocalDevelopmentHTTP
  ) -> ValidationOutcome {
    guard let scheme = components.scheme?.lowercased() else {
      return .rejected(reason: "scheme is missing")
    }
    guard let host = components.host?.lowercased() else {
      return .rejected(reason: "host is missing")
    }

    if scheme == "https", host == RestaurantMenuURLParser.requiredHost {
      if let port = components.port, port != 443 {
        return .rejected(reason: "port must be 443 or omitted")
      }
      return .allowed(.production)
    }

    if allowsLocalDevelopmentHTTP,
       RestaurantMenuDevelopmentHost.isLocalDevelopmentHost(host),
       scheme == "http" || scheme == "https" {
      return .allowed(.localDevelopment)
    }

    if scheme == "http" {
      return .rejected(reason: "scheme must be https")
    }

    return .rejected(reason: "host must be \(RestaurantMenuURLParser.requiredHost)")
  }
}
