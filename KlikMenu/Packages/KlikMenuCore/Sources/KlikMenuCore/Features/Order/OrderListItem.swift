import Foundation

public struct OrderListItem: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let restaurantID: String
    public let restaurantSlug: String
    public let menuItemID: String
    public let menuItemName: String
    public let variantID: String?
    public let variantLabel: String?
    public let variantDetail: String?
    public let unitPrice: String
    public let currency: String
    public var quantity: Int

    public init(
        restaurantID: String,
        restaurantSlug: String,
        menuItemID: String,
        menuItemName: String,
        variantID: String?,
        variantLabel: String?,
        variantDetail: String?,
        unitPrice: String,
        currency: String,
        quantity: Int
    ) {
        self.id = Self.lineKey(menuItemID: menuItemID, variantID: variantID)
        self.restaurantID = restaurantID
        self.restaurantSlug = restaurantSlug
        self.menuItemID = menuItemID
        self.menuItemName = menuItemName
        self.variantID = variantID
        self.variantLabel = variantLabel
        self.variantDetail = variantDetail
        self.unitPrice = unitPrice
        self.currency = currency
        self.quantity = quantity
    }

    public static func lineKey(menuItemID: String, variantID: String?) -> String {
        if let variantID {
            return "\(menuItemID)#\(variantID)"
        }
        return menuItemID
    }

    public var lineSubtotal: Decimal {
        guard let unit = OrderListCalculator.decimal(from: unitPrice) else { return 0 }
        return unit * Decimal(quantity)
    }
}
