import Foundation

/// Identifies local development hosts allowed to use HTTP in DEBUG builds.
struct RestaurantMenuDevelopmentHost: Sendable {
  static func isLocalDevelopmentHost(_ host: String?) -> Bool {
    guard let host = host?.lowercased() else { return false }

    if host == "localhost" || host == "127.0.0.1" || host == "::1" {
      return true
    }

    return isPrivateIPv4Address(host)
  }

  private static func isPrivateIPv4Address(_ host: String) -> Bool {
    let parts = host.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count == 4, parts.allSatisfy({ Int($0).map((0...255).contains) == true }) else {
      return false
    }

    let octets = parts.compactMap { Int($0) }
    guard octets.count == 4 else { return false }

    switch octets[0] {
    case 10:
      return true
    case 172 where (16...31).contains(octets[1]):
      return true
    case 192 where octets[1] == 168:
      return true
    default:
      return false
    }
  }
}
