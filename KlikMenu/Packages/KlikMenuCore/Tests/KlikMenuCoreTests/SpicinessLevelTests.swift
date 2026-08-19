import Foundation
import Testing
import KlikMenuCore

@Test func spicinessRawMappingCoversAllBackendValues() {
    #expect(SpicinessLevel(rawValue: "NONE") == SpicinessLevel.none)
    #expect(SpicinessLevel(rawValue: "SPICY") == .spicy)
    #expect(SpicinessLevel(rawValue: "MEDIUM_SPICY") == .mediumSpicy)
    #expect(SpicinessLevel(rawValue: "VERY_SPICY") == .verySpicy)
}

@Test func spicinessBadgeMappingUsesExpectedChiliCount() {
    #expect(SpicinessLevel.none.chiliCount == 0)
    #expect(SpicinessLevel.spicy.chiliCount == 1)
    #expect(SpicinessLevel.mediumSpicy.chiliCount == 2)
    #expect(SpicinessLevel.verySpicy.chiliCount == 3)
}

@Test func spicinessNoneDoesNotExposeBadgeLabel() {
    #expect(SpicinessLevel.none.displayLabel == nil)
    #expect(SpicinessLevel.none.accessibilityLabel == nil)
}

@Test func localizesSpicinessLabelsForPolishAndEnglish() {
    #expect(localizedValue(key: "Ostry", locale: "pl") == "Ostry")
    #expect(localizedValue(key: "Średnio ostry", locale: "en") == "Medium spicy")
    #expect(localizedValue(key: "Bardzo ostry", locale: "en") == "Very spicy")
}

@Test func localizesSpicinessAccessibilityForPolishAndEnglish() {
    #expect(localizedValue(key: "Ostry, poziom ostrości 1 z 3", locale: "pl") == "Ostry, poziom ostrości 1 z 3")
    #expect(localizedValue(key: "Ostry, poziom ostrości 1 z 3", locale: "en") == "Spicy, spiciness level 1 of 3")
}

@Test func menuItemCanBeVegetarianAndSpicyAtTheSameTime() {
    let item = MenuItem(
        id: "v1",
        categoryID: "c",
        subcategoryID: nil,
        name: "Veg curry",
        description: nil,
        ingredients: nil,
        servingSize: nil,
        allergens: [],
        price: "25.00",
        dietaryType: .vegetarian,
        spicinessLevel: .verySpicy,
        position: 0,
        isAvailable: true,
        imageURL: nil
    )

    #expect(item.dietaryType == .vegetarian)
    #expect(item.spicinessLevel == .verySpicy)
}

@Test func menuItemCanBeVeganAndSpicyAtTheSameTime() {
    let item = MenuItem(
        id: "v2",
        categoryID: "c",
        subcategoryID: nil,
        name: "Vegan ramen",
        description: nil,
        ingredients: nil,
        servingSize: nil,
        allergens: [],
        price: "26.00",
        dietaryType: .vegan,
        spicinessLevel: .mediumSpicy,
        position: 0,
        isAvailable: true,
        imageURL: nil
    )

    #expect(item.dietaryType == .vegan)
    #expect(item.spicinessLevel == .mediumSpicy)
}

@Test func menuItemWithVariantsKeepsSingleSpicinessOnItemLevel() {
    let item = MenuItem(
        id: "v3",
        categoryID: "c",
        subcategoryID: nil,
        name: "Soup",
        description: nil,
        ingredients: nil,
        servingSize: nil,
        allergens: [],
        price: "18.00",
        variants: [
            MenuItemVariant(id: "s", label: "Small", detail: nil, price: "18.00", position: 0),
            MenuItemVariant(id: "l", label: "Large", detail: nil, price: "24.00", position: 1),
        ],
        dietaryType: .none,
        spicinessLevel: .spicy,
        position: 0,
        isAvailable: true,
        imageURL: nil
    )

    #expect(item.variants.count == 2)
    #expect(item.spicinessLevel == .spicy)
}

private func localizedValue(key: String, locale: String) -> String? {
    let resourceURL = URL(filePath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appending(path: "Sources/KlikMenuCore/Resources/Localizable.xcstrings")

    guard let data = try? Data(contentsOf: resourceURL),
          let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let strings = root["strings"] as? [String: Any],
          let entry = strings[key] as? [String: Any],
          let localizations = entry["localizations"] as? [String: Any],
          let localeEntry = localizations[locale] as? [String: Any],
          let stringUnit = localeEntry["stringUnit"] as? [String: Any],
          let value = stringUnit["value"] as? String else {
        return nil
    }
    return value
}
