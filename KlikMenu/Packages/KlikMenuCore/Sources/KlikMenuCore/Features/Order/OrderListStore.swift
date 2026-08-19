import Foundation
import Observation

@MainActor
@Observable
public final class OrderListStore {
    public private(set) var items: [OrderListItem] = []
    public private(set) var orderListEnabled = false
    public private(set) var serviceCharge: ServiceCharge?
    public private(set) var restaurantID = ""
    public private(set) var restaurantSlug = ""
    public private(set) var currency = "PLN"

    public init() {}

    public func configure(menu: RestaurantMenu) {
        orderListEnabled = menu.orderListEnabled
        serviceCharge = menu.serviceCharge
        restaurantID = menu.id
        restaurantSlug = menu.slug
        currency = menu.currency

        if let persisted = OrderListPersistence.load(restaurantSlug: menu.slug),
           persisted.restaurantID == menu.id {
            items = persisted.items
        } else {
            items = []
        }
    }

    public func quantity(for lineKey: String) -> Int? {
        items.first(where: { $0.id == lineKey })?.quantity
    }

    public var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    public var productsSubtotal: Decimal {
        OrderListCalculator.productsSubtotal(items: items)
    }

    public var serviceChargeAmount: Decimal {
        OrderListCalculator.serviceChargeAmount(
            productsSubtotal: productsSubtotal,
            serviceCharge: serviceCharge
        )
    }

    public var total: Decimal {
        OrderListCalculator.total(
            productsSubtotal: productsSubtotal,
            serviceCharge: serviceCharge
        )
    }

    public var showsOrderUI: Bool {
        orderListEnabled
    }

    public var showsOrderBar: Bool {
        orderListEnabled && totalQuantity > 0
    }

    public func add(item: MenuItem, variant: MenuItemVariant?) {
        guard orderListEnabled else { return }

        let lineKey = OrderListItem.lineKey(menuItemID: item.id, variantID: variant?.id)
        if let index = items.firstIndex(where: { $0.id == lineKey }) {
            items[index].quantity += 1
        } else {
            items.append(
                OrderListItem(
                    restaurantID: restaurantID,
                    restaurantSlug: restaurantSlug,
                    menuItemID: item.id,
                    menuItemName: item.name,
                    variantID: variant?.id,
                    variantLabel: variant?.label,
                    variantDetail: variant?.detail,
                    unitPrice: variant?.price ?? item.price,
                    currency: currency,
                    quantity: 1
                )
            )
        }
        persist()
    }

    public func increment(lineKey: String) {
        guard orderListEnabled,
              let index = items.firstIndex(where: { $0.id == lineKey }) else { return }
        items[index].quantity += 1
        persist()
    }

    public func decrement(lineKey: String) {
        guard orderListEnabled,
              let index = items.firstIndex(where: { $0.id == lineKey }) else { return }
        if items[index].quantity <= 1 {
            items.remove(at: index)
        } else {
            items[index].quantity -= 1
        }
        persist()
    }

    public func remove(lineKey: String) {
        guard orderListEnabled else { return }
        items.removeAll { $0.id == lineKey }
        persist()
    }

    public func clear() {
        guard orderListEnabled else { return }
        items = []
        OrderListPersistence.clear(restaurantSlug: restaurantSlug)
    }

    private func persist() {
        guard !restaurantSlug.isEmpty else { return }
        if items.isEmpty {
            OrderListPersistence.clear(restaurantSlug: restaurantSlug)
            return
        }
        OrderListPersistence.save(
            PersistedOrderList(
                restaurantID: restaurantID,
                restaurantSlug: restaurantSlug,
                currency: currency,
                items: items
            )
        )
    }
}
