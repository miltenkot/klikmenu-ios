import Testing
import KlikMenuCore

@Test func normalizesPolishSearch() {
    #expect(normalizeMenuSearch("  Żółć Łódź ") == "zolc lodz")
}

@Test func filtersByNameIgnoringCaseAndWhitespace() {
    let item = MenuItem(
        id: "1",
        categoryID: "c",
        subcategoryID: nil,
        name: "Żurek staropolski",
        description: nil,
        ingredients: nil,
        servingSize: nil,
        allergens: [],
        price: "18.00",
        dietaryType: .none,
        position: 0,
        isAvailable: true,
        imageURL: nil
    )
    let category = MenuCategory(
        id: "c",
        name: "Zupy",
        description: nil,
        position: 0,
        items: [item],
        subcategories: []
    )
    var filters = MenuFilters(query: "  zur  ")
    #expect(filterMenuCategories([category], filters: filters).count == 1)

    filters.query = "pizza"
    #expect(filterMenuCategories([category], filters: filters).isEmpty)
}

@Test func filtersVegetarianAndVegan() {
    let vegetarian = MenuItem(
        id: "1", categoryID: "c", subcategoryID: nil, name: "Sałatka", description: nil,
        ingredients: nil, servingSize: nil, allergens: [], price: "10.00",
        dietaryType: .vegetarian, position: 0, isAvailable: true, imageURL: nil
    )
    let vegan = MenuItem(
        id: "2", categoryID: "c", subcategoryID: nil, name: "Tofu", description: nil,
        ingredients: nil, servingSize: nil, allergens: [], price: "12.00",
        dietaryType: .vegan, position: 1, isAvailable: true, imageURL: nil
    )
    let category = MenuCategory(
        id: "c", name: "Dania", description: nil, position: 0,
        items: [vegetarian, vegan], subcategories: []
    )

    var filters = MenuFilters(dietaryType: .vegetarian)
    #expect(filterMenuCategories([category], filters: filters).first?.items.map(\.item.id) == ["1"])

    filters.dietaryType = .vegan
    #expect(filterMenuCategories([category], filters: filters).first?.items.map(\.item.id) == ["2"])
}

@Test func filtersCategoryAndSubcategory() {
    let itemA = MenuItem(
        id: "a", categoryID: "c1", subcategoryID: "s1", name: "A", description: nil,
        ingredients: nil, servingSize: nil, allergens: [], price: "1.00",
        dietaryType: .none, position: 0, isAvailable: true, imageURL: nil
    )
    let itemB = MenuItem(
        id: "b", categoryID: "c1", subcategoryID: "s2", name: "B", description: nil,
        ingredients: nil, servingSize: nil, allergens: [], price: "2.00",
        dietaryType: .none, position: 1, isAvailable: true, imageURL: nil
    )
    let subcategory1 = MenuSubcategory(
        id: "s1", categoryID: "c1", name: "S1", description: nil, position: 0, items: [itemA]
    )
    let subcategory2 = MenuSubcategory(
        id: "s2", categoryID: "c1", name: "S2", description: nil, position: 1, items: [itemB]
    )
    let category = MenuCategory(
        id: "c1", name: "C1", description: nil, position: 0, items: [],
        subcategories: [subcategory1, subcategory2]
    )

    var filters = MenuFilters(categoryID: "c1", subcategoryID: "s2")
    let result = filterMenuCategories([category], filters: filters)
    #expect(result.first?.items.map(\.item.id) == ["b"])
}
