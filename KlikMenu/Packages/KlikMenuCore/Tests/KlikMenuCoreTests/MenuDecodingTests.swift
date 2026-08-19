import Foundation
import Testing
import KlikMenuCore

@Test func decodesMenuFixture() throws {
    let json = """
    {
      "data": {
        "id": "r",
        "name": "Bistro",
        "slug": "bistro",
        "description": "Opis",
        "address": "ul. Test 1",
        "phone": "+48111111111",
        "currency": "PLN",
        "isPublished": true,
        "feedbackEnabled": true,
        "createdAt": "2026-01-01T00:00:00Z",
        "updatedAt": "2026-01-01T00:00:00Z",
        "heroImageUrl": "https://cdn.example/hero.jpg",
        "requestedLocale": "en",
        "resolvedLocale": "en",
        "baseLocale": "pl",
        "availableLocales": ["pl", "en"],
        "supportedLocales": ["pl", "en", "de", "uk", "cs", "sk"],
        "categories": [
          {
            "id": "c-food",
            "restaurantId": "r",
            "name": "Food",
            "description": "Mains",
            "position": 0,
            "isVisible": true,
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-01-01T00:00:00Z",
            "items": [
              {
                "id": "i-direct",
                "categoryId": "c-food",
                "name": "Soup of the day",
                "description": "Chef special",
                "ingredients": "vegetables, stock",
                "servingSize": "300 ml",
                "subcategoryId": null,
                "allergens": ["celery"],
                "price": "18.00",
                "variants": [],
                "dietaryType": "VEGAN",
                "position": 0,
                "isAvailable": true,
                "isVisible": true,
                "imageUrl": "https://cdn.example/soup.jpg",
                "createdAt": "2026-01-01T00:00:00Z",
                "updatedAt": "2026-01-01T00:00:00Z"
              },
              {
                "id": "i-hidden",
                "categoryId": "c-food",
                "name": "Hidden",
                "description": null,
                "ingredients": null,
                "servingSize": null,
                "subcategoryId": null,
                "allergens": [],
                "price": "1.00",
                "variants": [],
                "dietaryType": "NONE",
                "position": 99,
                "isAvailable": true,
                "isVisible": false,
                "imageUrl": null,
                "createdAt": "2026-01-01T00:00:00Z",
                "updatedAt": "2026-01-01T00:00:00Z"
              }
            ],
            "subcategories": [
              {
                "id": "sc-burgers",
                "categoryId": "c-food",
                "name": "Burgers",
                "description": null,
                "position": 0,
                "isVisible": true,
                "createdAt": "2026-01-01T00:00:00Z",
                "updatedAt": "2026-01-01T00:00:00Z",
                "items": [
                  {
                    "id": "i-burger",
                    "categoryId": "c-food",
                    "name": "Klik Burger",
                    "description": "Beef burger",
                    "ingredients": "beef, bun",
                    "servingSize": "1 pc",
                    "subcategoryId": "sc-burgers",
                    "allergens": ["gluten", "milk"],
                    "price": "42.00",
                    "variants": [],
                    "dietaryType": "NONE",
                    "position": 0,
                    "isAvailable": true,
                    "isVisible": true,
                    "imageUrl": null,
                    "createdAt": "2026-01-01T00:00:00Z",
                    "updatedAt": "2026-01-01T00:00:00Z"
                  },
                  {
                    "id": "i-unavailable",
                    "categoryId": "c-food",
                    "name": "Sold out",
                    "description": null,
                    "ingredients": null,
                    "servingSize": null,
                    "subcategoryId": "sc-burgers",
                    "allergens": [],
                    "price": "10.00",
                    "variants": [],
                    "dietaryType": "VEGETARIAN",
                    "position": 1,
                    "isAvailable": false,
                    "isVisible": true,
                    "imageUrl": null,
                    "createdAt": "2026-01-01T00:00:00Z",
                    "updatedAt": "2026-01-01T00:00:00Z"
                  }
                ]
              }
            ]
          }
        ]
      }
    }
    """
    guard let data = json.data(using: .utf8) else {
        Issue.record("Invalid fixture encoding")
        return
    }
    let result = try JSONDecoder().decode(PublicMenuResponseDTO.self, from: data).data.asDomain()
    #expect(result.name == "Bistro")
    #expect(result.description == "Opis")
    #expect(result.heroImageURL?.absoluteString == "https://cdn.example/hero.jpg")
    #expect(result.feedbackEnabled)
    #expect(result.requestedLocale == .en)
    #expect(result.resolvedLocale == .en)
    #expect(result.baseLocale == .pl)
    #expect(result.availableLocales == [.pl, .en])
    #expect(result.supportedLocales == [.pl, .en, .de, .uk, .cs, .sk])
    #expect(result.categories.count == 1)

    let category = result.categories[0]
    #expect(category.name == "Food")
    #expect(category.items.count == 1)
    #expect(category.subcategories.count == 1)

    let direct = category.items[0]
    #expect(direct.name == "Soup of the day")
    #expect(direct.ingredients == "vegetables, stock")
    #expect(direct.servingSize == "300 ml")
    #expect(direct.allergens == ["celery"])
    #expect(direct.dietaryType == .vegan)
    #expect(direct.imageURL?.absoluteString == "https://cdn.example/soup.jpg")
    #expect(direct.subcategoryID == nil)
    #expect(direct.variants.isEmpty)

    let burger = category.subcategories[0].items[0]
    #expect(burger.name == "Klik Burger")
    #expect(burger.allergens == ["gluten", "milk"])
    #expect(burger.subcategoryID == "sc-burgers")
    #expect(category.subcategories[0].items.count == 1)
    #expect(PriceFormatter.string(price: "42.00", currency: "PLN").contains("42"))
}
