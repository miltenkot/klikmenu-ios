import Foundation
import Testing
import KlikMenuCore

@Test func decodesMenuItemWithEmptyVariantsWhenFieldMissing() throws {
    let json = """
    {
      "id": "i-1",
      "categoryId": "c",
      "name": "Burger",
      "description": null,
      "ingredients": null,
      "servingSize": null,
      "subcategoryId": null,
      "allergens": [],
      "price": "39.00",
      "dietaryType": "NONE",
      "position": 0,
      "isAvailable": true,
      "isVisible": true,
      "imageUrl": null,
      "createdAt": "2026-01-01T00:00:00Z",
      "updatedAt": "2026-01-01T00:00:00Z"
    }
    """
    let data = try #require(json.data(using: .utf8))
    let dto = try JSONDecoder().decode(MenuItemDTO.self, from: data)
    let item = dto.asDomain()

    #expect(item.variants.isEmpty)
    #expect(item.price == "39.00")
}

@Test func decodesMenuItemVariants() throws {
    let json = """
    {
      "id": "i-ulga",
      "categoryId": "c",
      "name": "Ulga",
      "description": "bezalkoholowe Sour Ale < 0,5%",
      "ingredients": null,
      "servingSize": null,
      "subcategoryId": null,
      "allergens": [],
      "price": "18.00",
      "variants": [
        {
          "id": "v-1",
          "menuItemId": "i-ulga",
          "label": "Butelka",
          "detail": "500 ml",
          "price": "19.00",
          "position": 0,
          "createdAt": "2026-01-01T00:00:00Z",
          "updatedAt": "2026-01-01T00:00:00Z"
        },
        {
          "id": "v-2",
          "menuItemId": "i-ulga",
          "label": "KEG",
          "detail": "500 ml",
          "price": "22",
          "position": 1,
          "createdAt": "2026-01-01T00:00:00Z",
          "updatedAt": "2026-01-01T00:00:00Z"
        },
        {
          "id": "v-3",
          "menuItemId": "i-ulga",
          "label": "KEG",
          "detail": null,
          "price": "12.50",
          "position": 2,
          "createdAt": "2026-01-01T00:00:00Z",
          "updatedAt": "2026-01-01T00:00:00Z"
        }
      ],
      "dietaryType": "NONE",
      "position": 0,
      "isAvailable": true,
      "isVisible": true,
      "imageUrl": null,
      "createdAt": "2026-01-01T00:00:00Z",
      "updatedAt": "2026-01-01T00:00:00Z"
    }
    """
    let data = try #require(json.data(using: .utf8))
    let item = try JSONDecoder().decode(MenuItemDTO.self, from: data).asDomain()

    #expect(item.variants.count == 3)
    #expect(item.variants.map(\.id) == ["v-1", "v-2", "v-3"])
    #expect(item.variants[0].label == "Butelka")
    #expect(item.variants[0].detail == "500 ml")
    #expect(item.variants[0].price == "19.00")
    #expect(item.variants[2].detail == nil)
    #expect(item.price == "18.00")
    #expect(PriceFormatter.string(price: item.variants[1].price, currency: "PLN").contains("22"))
    #expect(PriceFormatter.string(price: item.variants[2].price, currency: "PLN").contains("12"))
}

@Test func mapsBlankVariantDetailToNil() throws {
    let json = """
    {
      "id": "v-1",
      "menuItemId": "i-1",
      "label": "Mała",
      "detail": "   ",
      "price": "28.00",
      "position": 0,
      "createdAt": "2026-01-01T00:00:00Z",
      "updatedAt": "2026-01-01T00:00:00Z"
    }
    """
    let data = try #require(json.data(using: .utf8))
    let variant = try JSONDecoder().decode(MenuItemVariantDTO.self, from: data).asDomain()

    #expect(variant.detail == nil)
}

@Test func decodesPizzaVariantsWithoutDetail() throws {
    let json = """
    {
      "id": "i-pizza",
      "categoryId": "c",
      "name": "Pizza",
      "description": null,
      "ingredients": null,
      "servingSize": null,
      "subcategoryId": null,
      "allergens": [],
      "price": "28.00",
      "variants": [
        {
          "id": "v-small",
          "menuItemId": "i-pizza",
          "label": "Mała",
          "detail": null,
          "price": "28.00",
          "position": 0,
          "createdAt": "2026-01-01T00:00:00Z",
          "updatedAt": "2026-01-01T00:00:00Z"
        },
        {
          "id": "v-large",
          "menuItemId": "i-pizza",
          "label": "Duża",
          "detail": null,
          "price": "38.00",
          "position": 1,
          "createdAt": "2026-01-01T00:00:00Z",
          "updatedAt": "2026-01-01T00:00:00Z"
        }
      ],
      "dietaryType": "NONE",
      "position": 0,
      "isAvailable": true,
      "isVisible": true,
      "imageUrl": null,
      "createdAt": "2026-01-01T00:00:00Z",
      "updatedAt": "2026-01-01T00:00:00Z"
    }
    """
    let data = try #require(json.data(using: .utf8))
    let item = try JSONDecoder().decode(MenuItemDTO.self, from: data).asDomain()

    #expect(item.variants.count == 2)
    #expect(item.variants.allSatisfy { $0.detail == nil })
    #expect(item.variants.map(\.label) == ["Mała", "Duża"])
}
