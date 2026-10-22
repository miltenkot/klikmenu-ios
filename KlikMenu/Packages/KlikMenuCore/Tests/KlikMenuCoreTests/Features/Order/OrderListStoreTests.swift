import Foundation
import Testing
@testable import KlikMenuCore

@Suite
@MainActor
struct OrderListStoreTests {
    private let fixture = OrderListTestFixture()

    private func makeStore() -> OrderListStore {
        let store = OrderListStore()
        store.configure(menu: fixture.menu())
        return store
    }

    @Test func rejectsSavedOrderForDifferentRestaurantIDWithSameSlug() {
        defer { fixture.cleanUp() }
        let store = makeStore()
        store.add(item: fixture.item(), variant: nil)

        store.configure(menu: fixture.menu(restaurantID: "new-restaurant"))

        #expect(store.items.isEmpty)
        #expect(store.restaurantID == "new-restaurant")
        #expect(store.restaurantSlug == fixture.slug)
        #expect(!store.showsOrderBar)
    }

    @Test func corruptedStorageStartsEmptyAndCanBeReplacedByNewOrder() {
        defer { fixture.cleanUp() }
        UserDefaults.standard.set(Data("broken".utf8), forKey: fixture.storageKey)
        let store = makeStore()
        #expect(store.items.isEmpty)

        store.add(item: fixture.item(), variant: nil)

        #expect(makeStore().items == store.items)
        #expect(store.totalQuantity == 1)
    }

    @Test func incrementAndDecrementPersistQuantities() {
        defer { fixture.cleanUp() }
        let store = makeStore()
        let item = fixture.item()
        store.add(item: item, variant: nil)

        store.increment(lineKey: item.id)
        #expect(store.quantity(for: item.id) == 2)
        #expect(makeStore().quantity(for: item.id) == 2)

        store.decrement(lineKey: item.id)
        #expect(store.quantity(for: item.id) == 1)
        #expect(makeStore().quantity(for: item.id) == 1)
    }

    @Test(arguments: ["increment", "decrement", "remove"])
    func unknownLineDoesNotChangeOrder(operation: String) {
        defer { fixture.cleanUp() }
        let store = makeStore()
        store.add(item: fixture.item(), variant: nil)
        let original = store.items

        switch operation {
        case "increment": store.increment(lineKey: "missing")
        case "decrement": store.decrement(lineKey: "missing")
        default: store.remove(lineKey: "missing")
        }

        #expect(store.quantity(for: "missing") == nil)
        #expect(store.items == original)
        #expect(makeStore().items == original)
    }

    @Test(arguments: ["add", "increment", "decrement", "remove", "clear"])
    func disabledOrderCannotBeModified(operation: String) {
        defer { fixture.cleanUp() }
        let store = makeStore()
        let item = fixture.item()
        store.add(item: item, variant: nil)
        store.configure(menu: fixture.menu(enabled: false))
        let original = store.items

        switch operation {
        case "add": store.add(item: item, variant: nil)
        case "increment": store.increment(lineKey: item.id)
        case "decrement": store.decrement(lineKey: item.id)
        case "remove": store.remove(lineKey: item.id)
        default: store.clear()
        }

        #expect(!store.showsOrderUI)
        #expect(!store.showsOrderBar)
        #expect(store.items == original)
        #expect(makeStore().items == original)
    }

    @Test(arguments: ["clear", "remove", "decrement"])
    func removingLastItemPermanentlyClearsOrder(operation: String) {
        defer { fixture.cleanUp() }
        let store = makeStore()
        let item = fixture.item()
        store.add(item: item, variant: nil)
        #expect(store.showsOrderBar)

        switch operation {
        case "clear": store.clear()
        case "remove": store.remove(lineKey: item.id)
        default: store.decrement(lineKey: item.id)
        }

        #expect(store.items.isEmpty)
        #expect(store.totalQuantity == 0)
        #expect(!store.showsOrderBar)
        #expect(OrderListPersistence.load(restaurantSlug: fixture.slug) == nil)
        #expect(makeStore().items.isEmpty)
    }

    @Test func switchingBackRestoresEachRestaurantsOwnOrder() {
        let other = OrderListTestFixture()
        defer {
            fixture.cleanUp()
            other.cleanUp()
        }
        let store = makeStore()
        store.add(item: fixture.item(id: "first"), variant: nil)
        let firstItems = store.items

        store.configure(menu: other.menu(restaurantID: "other", currency: "EUR"))
        #expect(store.items.isEmpty)
        #expect(store.currency == "EUR")
        store.add(item: other.item(id: "second"), variant: nil)
        let secondItems = store.items

        store.configure(menu: fixture.menu())
        #expect(store.items == firstItems)
        #expect(store.currency == "PLN")

        store.configure(menu: other.menu(restaurantID: "other", currency: "EUR"))
        #expect(store.items == secondItems)
        #expect(store.restaurantID == "other")
    }

    @Test func totalsAndOrderBarFollowQuantityChanges() {
        defer { fixture.cleanUp() }
        let store = OrderListStore()
        store.configure(menu: fixture.menu(
            serviceCharge: ServiceCharge(type: .percentage, value: 10, label: "Obsługa")
        ))
        #expect(store.showsOrderUI)
        #expect(!store.showsOrderBar)

        let item = fixture.item()
        store.add(item: item, variant: nil)
        store.increment(lineKey: item.id)

        #expect(store.totalQuantity == 2)
        #expect(store.productsSubtotal == 25)
        #expect(store.serviceChargeAmount == Decimal(string: "2.50"))
        #expect(store.total == Decimal(string: "27.50"))
        #expect(store.showsOrderBar)
    }

    @Test func reAddingVariantUpdatesOnlyItsLineAndPersistsMetadata() throws {
        defer { fixture.cleanUp() }
        let store = makeStore()
        let item = fixture.item()
        let variant = MenuItemVariant(
            id: "large", label: "Duża", detail: "500 ml", price: "18.50", position: 0
        )
        store.add(item: item, variant: nil)
        store.add(item: item, variant: variant)
        store.add(item: item, variant: variant)

        let restored = makeStore()
        let line = try #require(restored.items.first { $0.variantID == variant.id })
        #expect(restored.items.count == 2)
        #expect(restored.quantity(for: item.id) == 1)
        #expect(line.quantity == 2)
        #expect(line.variantLabel == "Duża")
        #expect(line.variantDetail == "500 ml")
        #expect(line.unitPrice == "18.50")
        #expect(line.restaurantSlug == fixture.slug)
        #expect(line.currency == "PLN")
    }
}
