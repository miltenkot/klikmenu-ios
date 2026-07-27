import Foundation

public enum RestaurantMenuURLParser: Sendable {
  public static let requiredHost = "app.klikmenu.pl"
  public static let menuPathPrefix = "menu"

  public static func parse(_ urlString: String) -> RestaurantMenuRoute? {
    guard let url = URL(string: urlString) else { return nil }
    return parse(url)
  }

  public static func parse(_ url: URL) -> RestaurantMenuRoute? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return nil
    }
    return parse(components)
  }

  public static func parse(_ components: URLComponents) -> RestaurantMenuRoute? {
    guard components.scheme?.lowercased() == "https" else { return nil }
    guard components.host?.lowercased() == requiredHost else { return nil }

    if let port = components.port, port != 443 {
      return nil
    }

    let path = components.path
    let rawSegments = path.split(separator: "/", omittingEmptySubsequences: true)
    guard rawSegments.count == 2 else { return nil }
    guard rawSegments[0].lowercased() == menuPathPrefix else { return nil }

    let encodedSlug = String(rawSegments[1])
    guard !encodedSlug.isEmpty else { return nil }

    guard let decodedSlug = encodedSlug.removingPercentEncoding else { return nil }
    guard isValidSlug(decodedSlug) else { return nil }

    return RestaurantMenuRoute(slug: decodedSlug)
  }

  private static func isValidSlug(_ slug: String) -> Bool {
    guard !slug.isEmpty else { return false }
    if slug.contains("/") || slug.contains("\\") { return false }
    if slug.rangeOfCharacter(from: .whitespacesAndNewlines) != nil { return false }
    return true
  }
}
