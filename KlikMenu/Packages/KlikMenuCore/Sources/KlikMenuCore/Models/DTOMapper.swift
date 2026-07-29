import Foundation

extension RestaurantDTO {
    public func asDomain() -> RestaurantMenu {
        RestaurantMenu(
            id: id,
            name: name,
            slug: slug,
            description: description.nilIfBlank,
            address: address.nilIfBlank,
            phone: phone.nilIfBlank,
            currency: currency,
            heroImageURL: heroImageUrl.flatMap(URL.init(string:)),
            feedbackEnabled: feedbackEnabled,
            requestedLocale: requestedLocale.flatMap(SupportedLocale.init(rawValue:)),
            resolvedLocale: resolvedLocale.flatMap(SupportedLocale.init(rawValue:)),
            baseLocale: baseLocale.flatMap(SupportedLocale.init(rawValue:)),
            availableLocales: availableLocales.compactMap(SupportedLocale.init(rawValue:)),
            supportedLocales: supportedLocales.compactMap(SupportedLocale.init(rawValue:)),
            // Keep API array order (OpenAPI public menu already returns display order).
            categories: categories
                .filter(\.isVisible)
                .map { $0.asDomain() }
        )
    }
}

extension MenuCategoryDTO {
    public func asDomain() -> MenuCategory {
        MenuCategory(
            id: id,
            name: name,
            description: description.nilIfBlank,
            position: position,
            items: items
                .filter { $0.isVisible && $0.isAvailable }
                .map { $0.asDomain() },
            subcategories: subcategories
                .filter(\.isVisible)
                .map { $0.asDomain() }
        )
    }
}

extension MenuSubcategoryDTO {
    public func asDomain() -> MenuSubcategory {
        MenuSubcategory(
            id: id,
            categoryID: categoryId,
            name: name,
            description: description.nilIfBlank,
            position: position,
            items: items
                .filter { $0.isVisible && $0.isAvailable }
                .map { $0.asDomain() }
        )
    }
}

extension MenuItemDTO {
    public func asDomain() -> MenuItem {
        MenuItem(
            id: id,
            categoryID: categoryId,
            subcategoryID: subcategoryId,
            name: name,
            description: description.nilIfBlank,
            ingredients: ingredients.nilIfBlank,
            servingSize: servingSize.nilIfBlank,
            allergens: allergens,
            price: price,
            dietaryType: DietaryType(rawValue: dietaryType) ?? .none,
            position: position,
            isAvailable: isAvailable,
            imageURL: imageUrl.flatMap(URL.init(string:))
        )
    }
}

extension FeedbackConfigDTO {
    public func asDomain() -> FeedbackConfig {
        FeedbackConfig(
            enabled: enabled,
            restaurantName: restaurantName,
            baseLocale: SupportedLocale(rawValue: baseLocale) ?? .default,
            availableLocales: availableLocales.compactMap(SupportedLocale.init(rawValue:)),
            waiters: waiters.map {
                PublicWaiter(
                    id: $0.id,
                    name: $0.name,
                    photoURL: $0.photoUrl.flatMap(URL.init(string:))
                )
            }
        )
    }
}

extension Optional where Wrapped == String {
    fileprivate var nilIfBlank: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }
}
