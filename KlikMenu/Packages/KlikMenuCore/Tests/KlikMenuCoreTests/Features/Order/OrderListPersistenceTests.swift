import Foundation
import Testing
@testable import KlikMenuCore

@Suite
struct OrderListPersistenceTests {
    private let fixture = OrderListTestFixture()

    @Test func missingOrderReturnsNil() {
        defer { fixture.cleanUp() }
        #expect(OrderListPersistence.load(restaurantSlug: fixture.slug) == nil)
    }

    @Test(arguments: ["not JSON", "{}", #"{"items":"invalid"}"#])
    func invalidStoredDataReturnsNil(payload: String) {
        defer { fixture.cleanUp() }
        UserDefaults.standard.set(Data(payload.utf8), forKey: fixture.storageKey)
        #expect(OrderListPersistence.load(restaurantSlug: fixture.slug) == nil)
    }

    @Test func roundTripPreservesAllOrderAndVariantFields() {
        defer { fixture.cleanUp() }
        let order = fixture.persistedOrder()
        OrderListPersistence.save(order)
        #expect(OrderListPersistence.load(restaurantSlug: fixture.slug) == order)
    }

    @Test func saveReplacesExistingOrder() {
        defer { fixture.cleanUp() }
        OrderListPersistence.save(fixture.persistedOrder(quantity: 2))
        let updated = fixture.persistedOrder(quantity: 4)
        OrderListPersistence.save(updated)
        #expect(OrderListPersistence.load(restaurantSlug: fixture.slug) == updated)
    }

    @Test func clearRemovesOnlySelectedRestaurantAndIsRepeatable() {
        let other = OrderListTestFixture()
        defer {
            fixture.cleanUp()
            other.cleanUp()
        }
        OrderListPersistence.save(fixture.persistedOrder())
        OrderListPersistence.save(other.persistedOrder())

        OrderListPersistence.clear(restaurantSlug: fixture.slug)
        OrderListPersistence.clear(restaurantSlug: fixture.slug)

        #expect(UserDefaults.standard.object(forKey: fixture.storageKey) == nil)
        #expect(OrderListPersistence.load(restaurantSlug: fixture.slug) == nil)
        #expect(OrderListPersistence.load(restaurantSlug: other.slug) == other.persistedOrder())
    }
}
