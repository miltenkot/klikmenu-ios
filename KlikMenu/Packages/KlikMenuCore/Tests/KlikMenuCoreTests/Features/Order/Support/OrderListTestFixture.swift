import Foundation
@testable import KlikMenuCore

struct OrderListTestFixture {
    let slug = "order-test-\(UUID().uuidString)"

    // The versioned storage key is used only to inject invalid persisted data.
    var storageKey: String { "klikmenu.orderList.v1." + slug }

    func cleanUp() {
        OrderListPersistence.clear(restaurantSlug: slug)
    }

    func menu(
        restaurantID: String = "restaurant",
        enabled: Bool = true,
        currency: String = "PLN",
        serviceCharge: ServiceCharge? = nil
    ) -> RestaurantMenu {
        RestaurantMenu(
            id: restaurantID, name: "Bistro", slug: slug,
            description: nil, address: nil, phone: nil, currency: currency,
            heroImageURL: nil, orderListEnabled: enabled,
            serviceCharge: serviceCharge, categories: []
        )
    }

    func item(id: String = "soup") -> MenuItem {
        MenuItem(
            id: id, categoryID: "food", subcategoryID: nil, name: "Zupa",
            description: nil, ingredients: nil, servingSize: nil, allergens: [],
            price: "12.50", dietaryType: .none, position: 0,
            isAvailable: true, imageURL: nil
        )
    }

    func persistedOrder(quantity: Int = 2) -> PersistedOrderList {
        PersistedOrderList(
            restaurantID: "restaurant", restaurantSlug: slug, currency: "EUR",
            items: [
                OrderListItem(
                    restaurantID: "restaurant", restaurantSlug: slug,
                    menuItemID: "soup", menuItemName: "Żurek",
                    variantID: "large", variantLabel: "Duża",
                    variantDetail: "500 ml", unitPrice: "18.50",
                    currency: "EUR", quantity: quantity
                )
            ]
        )
    }
}
