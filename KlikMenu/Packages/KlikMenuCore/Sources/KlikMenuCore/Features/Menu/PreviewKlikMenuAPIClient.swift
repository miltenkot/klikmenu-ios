import Foundation

struct PreviewKlikMenuAPIClient: KlikMenuAPIClient {
    var delayNanoseconds: UInt64 = 0
    var shouldFailAsNotFound = false

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        if shouldFailAsNotFound {
            throw APIError.notFound
        }
        return PreviewRestaurantMenu.make(slug: slug, locale: locale)
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig {
        if shouldFailAsNotFound {
            throw APIError.notFound
        }
        return FeedbackConfig(
            enabled: true,
            restaurantName: PreviewRestaurantMenu.name,
            waiters: [
                PublicWaiter(id: "w1", name: "Anna", photoURL: nil),
                PublicWaiter(id: "w2", name: "Piotr", photoURL: nil),
            ]
        )
    }

    func submitFeedback(
        slug: String,
        request: FeedbackRequest
    ) async throws -> SubmitFeedbackResponseDTO {
        SubmitFeedbackResponseDTO(accepted: true)
    }
}

enum PreviewRestaurantMenu {
    static let slug = "bistro-klik"
    static let name = "Bistro Klik"

    static func make(slug: String, locale: SupportedLocale) -> RestaurantMenu {
        let categoryID = "cat-starters"
        let mainsID = "cat-mains"

        return RestaurantMenu(
            id: "preview-restaurant",
            name: name,
            slug: slug,
            description: "Nowoczesne bistro z sezonowym menu i lokalnymi produktami.",
            address: "ul. Przykładowa 12, Warszawa",
            phone: "+48 123 456 789",
            currency: "PLN",
            heroImageURL: nil,
            feedbackEnabled: true,
            requestedLocale: locale,
            resolvedLocale: locale,
            baseLocale: .pl,
            availableLocales: [.pl, .en],
            supportedLocales: [.pl, .en],
            orderListEnabled: true,
            categories: [
                MenuCategory(
                    id: categoryID,
                    name: "Przystawki",
                    description: "Lekki start",
                    position: 0,
                    items: [
                        MenuItem(
                            id: "item-bruschetta",
                            categoryID: categoryID,
                            subcategoryID: nil,
                            name: "Bruschetta",
                            description: "Chrupiąca bagietka z pomidorami, bazylią i oliwą.",
                            ingredients: "bagietka, pomidor, bazylia, oliwa",
                            servingSize: "180 g",
                            allergens: ["gluten"],
                            price: "24.00",
                            dietaryType: .vegetarian,
                            spicinessLevel: .none,
                            position: 0,
                            isAvailable: true,
                            imageURL: nil
                        ),
                        MenuItem(
                            id: "item-soup",
                            categoryID: categoryID,
                            subcategoryID: nil,
                            name: "Zupa dnia",
                            description: "Krem z pieczonych warzyw.",
                            ingredients: nil,
                            servingSize: "300 ml",
                            allergens: [],
                            price: "18.00",
                            dietaryType: .vegan,
                            spicinessLevel: .none,
                            position: 1,
                            isAvailable: true,
                            imageURL: nil
                        ),
                    ],
                    subcategories: []
                ),
                MenuCategory(
                    id: mainsID,
                    name: "Dania główne",
                    description: nil,
                    position: 1,
                    items: [
                        MenuItem(
                            id: "item-burger",
                            categoryID: mainsID,
                            subcategoryID: nil,
                            name: "Burger klasyczny",
                            description: "Wołowina, cheddar, marynowana czerwona cebula.",
                            ingredients: "bułka, wołowina, cheddar, sałata, cebula",
                            servingSize: nil,
                            allergens: ["gluten", "mleko"],
                            price: "42.00",
                            variants: [
                                MenuItemVariant(
                                    id: "var-single",
                                    label: "Pojedynczy",
                                    detail: nil,
                                    price: "42.00",
                                    position: 0
                                ),
                                MenuItemVariant(
                                    id: "var-double",
                                    label: "Podwójny",
                                    detail: "+ kotlet",
                                    price: "54.00",
                                    position: 1
                                ),
                            ],
                            dietaryType: .none,
                            spicinessLevel: .mediumSpicy,
                            position: 0,
                            isAvailable: true,
                            imageURL: nil
                        ),
                        MenuItem(
                            id: "item-pasta",
                            categoryID: mainsID,
                            subcategoryID: nil,
                            name: "Pasta arrabbiata",
                            description: "Penne w ostrym sosie pomidorowym.",
                            ingredients: "penne, pomidor, czosnek, chili",
                            servingSize: "350 g",
                            allergens: ["gluten"],
                            price: "36.00",
                            dietaryType: .vegetarian,
                            spicinessLevel: .spicy,
                            position: 1,
                            isAvailable: true,
                            imageURL: nil
                        ),
                    ],
                    subcategories: []
                ),
            ]
        )
    }
}
