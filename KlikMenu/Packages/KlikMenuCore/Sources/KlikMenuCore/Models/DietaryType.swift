import Foundation

public enum DietaryType: String, Codable, Sendable, Equatable, CaseIterable {
    case none = "NONE"
    case vegetarian = "VEGETARIAN"
    case vegan = "VEGAN"

    public var displayLabel: String? {
        switch self {
        case .none: nil
        case .vegetarian: "Wegetariańskie"
        case .vegan: "Wegańskie"
        }
    }
}
