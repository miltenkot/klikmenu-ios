import Foundation

public enum DietaryType: String, Codable, Sendable, Equatable, CaseIterable {
    case none = "NONE"
    case vegetarian = "VEGETARIAN"
    case vegan = "VEGAN"

    public var displayLabel: LocalizedStringResource? {
        switch self {
        case .none: nil
        case .vegetarian: LocalizedStringResource("Wegetariańskie", bundle: #bundle)
        case .vegan: LocalizedStringResource("Wegańskie", bundle: #bundle)
        }
    }
}
