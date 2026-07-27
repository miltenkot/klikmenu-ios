import Foundation

public enum DietaryType: String, Codable, Sendable, Equatable, CaseIterable {
  case none = "NONE"
  case vegetarian = "VEGETARIAN"
  case vegan = "VEGAN"
}
