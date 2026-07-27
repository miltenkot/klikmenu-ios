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
        "description": null,
        "address": null,
        "phone": null,
        "currency": "PLN",
        "isPublished": true,
        "feedbackEnabled": true,
        "createdAt": "2026-01-01T00:00:00Z",
        "updatedAt": "2026-01-01T00:00:00Z",
        "heroImageUrl": null,
        "categories": [
          {
            "id": "c",
            "restaurantId": "r",
            "name": "Dania",
            "description": null,
            "position": 1,
            "isVisible": true,
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-01-01T00:00:00Z",
            "items": [
              {
                "id": "i",
                "categoryId": "c",
                "name": "Żurek",
                "description": null,
                "ingredients": null,
                "servingSize": null,
                "subcategoryId": null,
                "allergens": [],
                "price": "24.00",
                "dietaryType": "VEGETARIAN",
                "position": 1,
                "isAvailable": true,
                "isVisible": true,
                "imageUrl": null,
                "createdAt": "2026-01-01T00:00:00Z",
                "updatedAt": "2026-01-01T00:00:00Z"
              }
            ],
            "subcategories": []
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
    #expect(result.categories[0].items[0].dietaryType == .vegetarian)
    #expect(PriceFormatter.string(price: "24.00", currency: "PLN").contains("24"))
}
