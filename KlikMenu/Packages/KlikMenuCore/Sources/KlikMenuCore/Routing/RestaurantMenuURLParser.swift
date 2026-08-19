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
    parse(
      components,
      allowsLocalDevelopmentHTTP: RestaurantMenuURLSecurityPolicy.allowsLocalDevelopmentHTTP
    )
  }

  static func parse(
    _ components: URLComponents,
    allowsLocalDevelopmentHTTP: Bool
  ) -> RestaurantMenuRoute? {
    switch RestaurantMenuURLSecurityPolicy.validate(
      components: components,
      allowsLocalDevelopmentHTTP: allowsLocalDevelopmentHTTP
    ) {
    case .allowed:
      break
    case .rejected:
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

  /// OpenAPI restaurant slug: `^[a-z0-9]+(?:-[a-z0-9]+)*$` (max 120).
  private static func isValidSlug(_ slug: String) -> Bool {
    guard (1...120).contains(slug.count) else { return false }
    return slug.wholeMatch(of: /^[a-z0-9]+(?:-[a-z0-9]+)*$/) != nil
  }
}
