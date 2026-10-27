import Testing
@testable import KlikMenuCore

@Suite
@MainActor
struct RestaurantMenuFeedRowsTests {
    @Test
    func refreshesRowsForSameRestaurantWhenContentAndCurrencyChange() async throws {
        let api = ScriptedMenuAPI([
            .success(menu(name: "Soup", currency: "PLN")),
            .success(menu(name: "Zupa", currency: "EUR")),
            .success(emptyMenu(slug: "bistro"))
        ])
        let model = RestaurantMenuViewModel(api: api)
        #expect(model.feedRows.isEmpty)

        await model.load(slug: "bistro")
        #expect(model.feedRows.count == 2)
        guard case let .item(first, firstCurrency, _, _) = try #require(model.feedRows.last) else {
            Issue.record("Expected an item row")
            return
        }
        #expect(first.name == "Soup")
        #expect(firstCurrency == "PLN")

        await model.retry()
        #expect(model.feedRows.count == 2)
        guard case let .item(updated, updatedCurrency, _, _) = try #require(model.feedRows.last) else {
            Issue.record("Expected an updated item row")
            return
        }
        #expect(updated.name == "Zupa")
        #expect(updatedCurrency == "EUR")

        await model.retry()
        #expect(model.state == .empty)
        #expect(model.feedRows.isEmpty)
    }

    @Test
    func clearsRowsWhenMenuLoadFails() async {
        let api = ScriptedMenuAPI([
            .success(menu(name: "Soup", currency: "PLN")),
            .failure(APIError.network)
        ])
        let model = RestaurantMenuViewModel(api: api)
        await model.load(slug: "bistro")
        #expect(!model.feedRows.isEmpty)

        await model.retry()
        #expect(model.menu == nil)
        #expect(model.feedRows.isEmpty)
    }

    private func menu(name: String, currency: String) -> RestaurantMenu {
        let item = MenuItem(
            id: "soup", categoryID: "food", subcategoryID: nil, name: name,
            description: nil, ingredients: nil, servingSize: nil, allergens: [],
            price: "10", dietaryType: .none, position: 0, isAvailable: true, imageURL: nil
        )
        return RestaurantMenu(
            id: "bistro", name: "Bistro", slug: "bistro", description: nil,
            address: nil, phone: nil, currency: currency, heroImageURL: nil,
            categories: [
                MenuCategory(
                    id: "food", name: "Food", description: nil, position: 0,
                    items: [item], subcategories: []
                )
            ]
        )
    }
}
