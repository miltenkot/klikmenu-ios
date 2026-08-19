import Foundation

struct PersistedOrderList: Codable, Sendable, Equatable {
    let restaurantID: String
    let restaurantSlug: String
    let currency: String
    var items: [OrderListItem]
}

enum OrderListPersistence {
    private static let keyPrefix = "klikmenu.orderList.v1."

    static func load(restaurantSlug: String) -> PersistedOrderList? {
        guard let data = UserDefaults.standard.data(forKey: storageKey(restaurantSlug: restaurantSlug)) else {
            return nil
        }
        return try? JSONDecoder().decode(PersistedOrderList.self, from: data)
    }

    static func save(_ orderList: PersistedOrderList) {
        guard let data = try? JSONEncoder().encode(orderList) else { return }
        UserDefaults.standard.set(data, forKey: storageKey(restaurantSlug: orderList.restaurantSlug))
    }

    static func clear(restaurantSlug: String) {
        UserDefaults.standard.removeObject(forKey: storageKey(restaurantSlug: restaurantSlug))
    }

    private static func storageKey(restaurantSlug: String) -> String {
        keyPrefix + restaurantSlug
    }
}
