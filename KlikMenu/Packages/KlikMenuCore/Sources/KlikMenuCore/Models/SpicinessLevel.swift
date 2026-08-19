import Foundation

public enum SpicinessLevel: String, Codable, Sendable, Equatable, CaseIterable {
    case none = "NONE"
    case spicy = "SPICY"
    case mediumSpicy = "MEDIUM_SPICY"
    case verySpicy = "VERY_SPICY"

    public var displayLabel: LocalizedStringResource? {
        switch self {
        case .none:
            nil
        case .spicy:
            LocalizedStringResource("Ostry", bundle: #bundle)
        case .mediumSpicy:
            LocalizedStringResource("Średnio ostry", bundle: #bundle)
        case .verySpicy:
            LocalizedStringResource("Bardzo ostry", bundle: #bundle)
        }
    }

    public var chiliCount: Int {
        switch self {
        case .none:
            0
        case .spicy:
            1
        case .mediumSpicy:
            2
        case .verySpicy:
            3
        }
    }

    public var accessibilityLabel: LocalizedStringResource? {
        switch self {
        case .none:
            nil
        case .spicy:
            LocalizedStringResource("Ostry, poziom ostrości 1 z 3", bundle: #bundle)
        case .mediumSpicy:
            LocalizedStringResource("Średnio ostry, poziom ostrości 2 z 3", bundle: #bundle)
        case .verySpicy:
            LocalizedStringResource("Bardzo ostry, poziom ostrości 3 z 3", bundle: #bundle)
        }
    }
}
