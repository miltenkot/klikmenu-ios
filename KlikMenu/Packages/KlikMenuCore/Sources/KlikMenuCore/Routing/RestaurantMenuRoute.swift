import Foundation

public struct RestaurantMenuRoute: Equatable, Sendable {
  public let slug: String

  public init(slug: String) {
    self.slug = slug
  }
}
