import Foundation

public struct ServiceCharge: Sendable, Equatable {
    public enum ChargeType: String, Sendable, Equatable {
        case fixed = "FIXED"
        case percentage = "PERCENTAGE"
    }

    public let type: ChargeType
    public let value: Decimal
    public let label: String

    public init(type: ChargeType, value: Decimal, label: String) {
        self.type = type
        self.value = value
        self.label = label
    }
}
