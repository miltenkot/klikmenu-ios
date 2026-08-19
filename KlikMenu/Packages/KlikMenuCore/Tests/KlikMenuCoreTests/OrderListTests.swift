import Foundation
import Testing
@testable import KlikMenuCore

@Suite struct OrderListTests {
    private let posix = Locale(identifier: "en_US_POSIX")

    @Test @MainActor
    func hidesOrderUIWhenDisabled() {
        let slug = uniqueSlug()
        let store = OrderListStore()
        store.configure(menu: makeMenu(slug: slug, orderListEnabled: false))

        #expect(store.showsOrderUI == false)
        #expect(store.showsOrderBar == false)

        OrderListPersistence.clear(restaurantSlug: slug)
    }

    @Test @MainActor
    func addsStandardItem() {
        let slug = uniqueSlug()
        let store = OrderListStore()
        store.configure(menu: makeMenu(slug: slug))
        let item = makeItem(id: "burger", name: "Burger", price: "25.00")

        store.add(item: item, variant: nil)

        #expect(store.items.count == 1)
        #expect(store.items[0].menuItemID == "burger")
        #expect(store.items[0].quantity == 1)
        #expect(store.items[0].unitPrice == "25.00")
        #expect(store.items[0].variantID == nil)

        OrderListPersistence.clear(restaurantSlug: slug)
    }

    @Test @MainActor
    func reAddIncreasesQuantity() {
        let slug = uniqueSlug()
        let store = OrderListStore()
        store.configure(menu: makeMenu(slug: slug))
        let item = makeItem(id: "burger", name: "Burger", price: "25.00")

        store.add(item: item, variant: nil)
        store.add(item: item, variant: nil)

        #expect(store.items.count == 1)
        #expect(store.items[0].quantity == 2)
        #expect(store.totalQuantity == 2)

        OrderListPersistence.clear(restaurantSlug: slug)
    }

    @Test @MainActor
    func removeLine() {
        let slug = uniqueSlug()
        let store = OrderListStore()
        store.configure(menu: makeMenu(slug: slug))
        let item = makeItem(id: "burger", name: "Burger", price: "25.00")
        store.add(item: item, variant: nil)

        store.remove(lineKey: item.id)

        #expect(store.items.isEmpty)

        OrderListPersistence.clear(restaurantSlug: slug)
    }

    @Test @MainActor
    func decrementFromOneRemovesLine() {
        let slug = uniqueSlug()
        let store = OrderListStore()
        store.configure(menu: makeMenu(slug: slug))
        let item = makeItem(id: "burger", name: "Burger", price: "25.00")
        store.add(item: item, variant: nil)

        store.decrement(lineKey: item.id)

        #expect(store.items.isEmpty)

        OrderListPersistence.clear(restaurantSlug: slug)
    }

    @Test @MainActor
    func keepsSeparateLinesForTwoVariants() {
        let slug = "variants-\(UUID().uuidString)"
        let store = OrderListStore()
        store.configure(menu: makeMenu(slug: slug))
        let item = makeItem(
            id: "ulga",
            name: "Ulga",
            price: "18.00",
            variants: [
                MenuItemVariant(id: "v1", label: "Keg 500 ml", detail: nil, price: "22.00", position: 0),
                MenuItemVariant(id: "v2", label: "Butelka", detail: "330 ml", price: "16.00", position: 1)
            ]
        )

        store.add(item: item, variant: item.variants[0])
        store.add(item: item, variant: item.variants[1])

        #expect(store.items.count == 2)
        #expect(store.items.compactMap(\.variantID).sorted() == ["v1", "v2"])
        #expect(store.items.first(where: { $0.variantID == "v1" })?.unitPrice == "22.00")
        #expect(store.items.first(where: { $0.variantID == "v2" })?.unitPrice == "16.00")

        OrderListPersistence.clear(restaurantSlug: slug)
    }

    @Test @MainActor
    func persistsAcrossStoreInstances() {
        let slug = "persist-\(UUID().uuidString)"
        let menu = makeMenu(slug: slug, restaurantID: "r-persist")

        let first = OrderListStore()
        first.configure(menu: menu)
        first.add(item: makeItem(id: "soup", name: "Soup", price: "12.00"), variant: nil)

        let second = OrderListStore()
        second.configure(menu: menu)

        #expect(second.items.count == 1)
        #expect(second.items[0].menuItemName == "Soup")

        OrderListPersistence.clear(restaurantSlug: slug)
    }

    @Test @MainActor
    func isolatesRestaurants() {
        let slugA = "a-\(UUID().uuidString)"
        let slugB = "b-\(UUID().uuidString)"
        let menuA = makeMenu(slug: slugA, restaurantID: "a")
        let menuB = makeMenu(slug: slugB, restaurantID: "b")

        let store = OrderListStore()
        store.configure(menu: menuA)
        store.add(item: makeItem(id: "a-item", name: "A", price: "10.00"), variant: nil)

        store.configure(menu: menuB)

        #expect(store.items.isEmpty)

        OrderListPersistence.clear(restaurantSlug: slugA)
        OrderListPersistence.clear(restaurantSlug: slugB)
    }

    @Test
    func fixedServiceChargeUsesFlatValue() {
        let items = [
            makeOrderLine(unitPrice: "45.00", quantity: 2)
        ]
        let charge = ServiceCharge(type: .fixed, value: Decimal(string: "10", locale: posix)!, label: "Obsługa kelnerska")

        let subtotal = OrderListCalculator.productsSubtotal(items: items)
        let amount = OrderListCalculator.serviceChargeAmount(productsSubtotal: subtotal, serviceCharge: charge)
        let total = OrderListCalculator.total(productsSubtotal: subtotal, serviceCharge: charge)

        #expect(subtotal == Decimal(string: "90.00", locale: posix))
        #expect(amount == Decimal(string: "10.00", locale: posix))
        #expect(total == Decimal(string: "100.00", locale: posix))
    }

    @Test
    func percentageServiceChargeUsesSubtotal() {
        let items = [
            makeOrderLine(unitPrice: "45.00", quantity: 2)
        ]
        let charge = ServiceCharge(type: .percentage, value: Decimal(string: "10", locale: posix)!, label: "Opłata za obsługę")

        let subtotal = OrderListCalculator.productsSubtotal(items: items)
        let amount = OrderListCalculator.serviceChargeAmount(productsSubtotal: subtotal, serviceCharge: charge)
        let total = OrderListCalculator.total(productsSubtotal: subtotal, serviceCharge: charge)

        #expect(amount == Decimal(string: "9.00", locale: posix))
        #expect(total == Decimal(string: "99.00", locale: posix))
    }

    @Test
    func roundsServiceChargeToTwoDecimals() {
        let subtotal = Decimal(string: "33.33", locale: posix)!
        let charge = ServiceCharge(type: .percentage, value: Decimal(string: "10", locale: posix)!, label: "Opłata")

        let amount = OrderListCalculator.serviceChargeAmount(productsSubtotal: subtotal, serviceCharge: charge)

        #expect(amount == Decimal(string: "3.33", locale: posix))
    }

    @Test
    func finalTotalIncludesServiceCharge() {
        let items = [makeOrderLine(unitPrice: "18.50", quantity: 3)]
        let charge = ServiceCharge(type: .percentage, value: Decimal(string: "8", locale: posix)!, label: "Opłata")

        let subtotal = OrderListCalculator.productsSubtotal(items: items)
        let total = OrderListCalculator.total(productsSubtotal: subtotal, serviceCharge: charge)

        #expect(total == Decimal(string: "59.94", locale: posix))
    }

    @Test
    func usesBackendServiceChargeLabel() {
        let charge = ServiceCharge(type: .fixed, value: 5, label: "Obsługa kelnerska")
        #expect(charge.label == "Obsługa kelnerska")
        #expect(OrderListCalculator.percentageSuffix(for: charge) == nil)
    }

    @Test
    func nilServiceChargeProducesZeroFee() {
        let items = [makeOrderLine(unitPrice: "20.00", quantity: 2)]
        let subtotal = OrderListCalculator.productsSubtotal(items: items)
        let amount = OrderListCalculator.serviceChargeAmount(productsSubtotal: subtotal, serviceCharge: nil)
        let total = OrderListCalculator.total(productsSubtotal: subtotal, serviceCharge: nil)

        #expect(amount == 0)
        #expect(total == Decimal(string: "40.00", locale: posix))
    }

    @Test(arguments: [
        ("pl", "Twoje zamówienie"),
        ("en", "Your order"),
        ("de", "Deine Bestellung"),
        ("sk", "Vaša objednávka"),
        ("cs", "Vaše objednávka"),
        ("uk", "Ваше замовлення")
    ])
    func localizesOrderTitle(locale: String, expected: String) throws {
        #expect(try catalogString(key: "Twoje zamówienie", locale: locale) == expected)
    }

    @Test(arguments: [
        ("pl", "Suma produktów"),
        ("en", "Items subtotal"),
        ("de", "Zwischensumme"),
        ("sk", "Medzisúčet"),
        ("cs", "Mezisoučet"),
        ("uk", "Сума товарів")
    ])
    func localizesProductsSubtotal(locale: String, expected: String) throws {
        #expect(try catalogString(key: "Suma produktów", locale: locale) == expected)
    }

    @Test(arguments: [
        ("pl", "Razem"),
        ("en", "Total"),
        ("de", "Gesamt"),
        ("sk", "Spolu"),
        ("cs", "Celkem"),
        ("uk", "Разом")
    ])
    func localizesTotal(locale: String, expected: String) throws {
        #expect(try catalogString(key: "Razem", locale: locale) == expected)
    }

    @Test(arguments: [
        ("pl", "Dodaj"),
        ("en", "Add"),
        ("de", "Hinzufügen"),
        ("sk", "Pridať"),
        ("cs", "Přidat"),
        ("uk", "Додати")
    ])
    func localizesAdd(locale: String, expected: String) throws {
        #expect(try catalogString(key: "Dodaj", locale: locale) == expected)
    }

    @Test(arguments: [
        ("pl", "Wyczyść"),
        ("en", "Clear"),
        ("de", "Leeren"),
        ("sk", "Vymazať"),
        ("cs", "Vymazat"),
        ("uk", "Очистити")
    ])
    func localizesClear(locale: String, expected: String) throws {
        #expect(try catalogString(key: "Wyczyść", locale: locale) == expected)
    }

    @Test(arguments: [
        ("pl", "Usuń"),
        ("en", "Remove"),
        ("de", "Entfernen"),
        ("sk", "Odstrániť"),
        ("cs", "Odstranit"),
        ("uk", "Видалити")
    ])
    func localizesRemove(locale: String, expected: String) throws {
        #expect(try catalogString(key: "Usuń", locale: locale) == expected)
    }

    @Test(arguments: [
        ("pl", "Pokaż tę listę kelnerowi, aby łatwiej złożyć zamówienie."),
        ("en", "Show this list to your waiter to make ordering easier."),
        ("de", "Zeige diese Liste dem Servicepersonal, um die Bestellung zu erleichtern."),
        ("sk", "Ukážte tento zoznam obsluhe, aby ste si objednávku uľahčili."),
        ("cs", "Ukažte tento seznam obsluze, aby bylo objednání jednodušší."),
        ("uk", "Покажіть цей список офіціанту, щоб було легше зробити замовлення.")
    ])
    func localizesWaiterHint(locale: String, expected: String) throws {
        #expect(
            try catalogString(
                key: "Pokaż tę listę kelnerowi, aby łatwiej złożyć zamówienie.",
                locale: locale
            ) == expected
        )
    }

    private func uniqueSlug() -> String {
        "test-\(UUID().uuidString)"
    }

    private func catalogString(key: String, locale: String) throws -> String {
        guard let url = Bundle.module.url(forResource: "Localizable", withExtension: "xcstrings") else {
            throw CatalogError.missingResource
        }
        let data = try Data(contentsOf: url)
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let strings = json["strings"] as? [String: Any],
            let entry = strings[key] as? [String: Any],
            let localizations = entry["localizations"] as? [String: Any],
            let localeEntry = localizations[locale] as? [String: Any],
            let stringUnit = localeEntry["stringUnit"] as? [String: Any],
            let value = stringUnit["value"] as? String
        else {
            throw CatalogError.missingTranslation(key: key, locale: locale)
        }
        return value
    }

    private enum CatalogError: Error {
        case missingResource
        case missingTranslation(key: String, locale: String)
    }

    private func makeMenu(
        slug: String = "bistro",
        restaurantID: String = "r1",
        orderListEnabled: Bool = true,
        serviceCharge: ServiceCharge? = nil
    ) -> RestaurantMenu {
        RestaurantMenu(
            id: restaurantID,
            name: "Bistro",
            slug: slug,
            description: nil,
            address: nil,
            phone: nil,
            currency: "PLN",
            heroImageURL: nil,
            orderListEnabled: orderListEnabled,
            serviceCharge: serviceCharge,
            categories: []
        )
    }

    private func makeItem(
        id: String,
        name: String,
        price: String,
        variants: [MenuItemVariant] = []
    ) -> MenuItem {
        MenuItem(
            id: id,
            categoryID: "c1",
            subcategoryID: nil,
            name: name,
            description: nil,
            ingredients: nil,
            servingSize: nil,
            allergens: [],
            price: price,
            variants: variants,
            dietaryType: .none,
            position: 0,
            isAvailable: true,
            imageKey: nil,
            imageURL: nil
        )
    }

    private func makeOrderLine(unitPrice: String, quantity: Int) -> OrderListItem {
        OrderListItem(
            restaurantID: "r1",
            restaurantSlug: "bistro",
            menuItemID: "item",
            menuItemName: "Item",
            variantID: nil,
            variantLabel: nil,
            variantDetail: nil,
            unitPrice: unitPrice,
            currency: "PLN",
            quantity: quantity
        )
    }
}
