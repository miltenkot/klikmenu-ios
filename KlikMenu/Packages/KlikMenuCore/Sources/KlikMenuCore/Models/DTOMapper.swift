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
            categories: categories
                .filter(\.isVisible)
                .map { $0.asDomain() }
                .sorted { $0.position < $1.position }
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
                .map { $0.asDomain() }
                .sorted { $0.position < $1.position },
            subcategories: subcategories
                .filter(\.isVisible)
                .map { $0.asDomain() }
                .sorted { $0.position < $1.position }
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
                .sorted { $0.position < $1.position }
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
