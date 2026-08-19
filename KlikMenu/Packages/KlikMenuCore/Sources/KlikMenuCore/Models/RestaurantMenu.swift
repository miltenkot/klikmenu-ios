import Foundation

public struct RestaurantMenu: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String?
    public let address: String?
    public let phone: String?
    public let currency: String
    public let heroImageKey: String?
    public let heroImageURL: URL?
    public let feedbackEnabled: Bool
    public let requestedLocale: SupportedLocale?
    public let resolvedLocale: SupportedLocale?
    public let baseLocale: SupportedLocale?
    public let availableLocales: [SupportedLocale]
    public let supportedLocales: [SupportedLocale]
    public let categories: [MenuCategory]

    public init(
        id: String,
        name: String,
        slug: String,
        description: String?,
        address: String?,
        phone: String?,
        currency: String,
        heroImageKey: String? = nil,
        heroImageURL: URL?,
        feedbackEnabled: Bool = false,
        requestedLocale: SupportedLocale? = nil,
        resolvedLocale: SupportedLocale? = nil,
        baseLocale: SupportedLocale? = nil,
        availableLocales: [SupportedLocale] = [],
        supportedLocales: [SupportedLocale] = [],
        categories: [MenuCategory]
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.address = address
        self.phone = phone
        self.currency = currency
        self.heroImageKey = heroImageKey
        self.heroImageURL = heroImageURL
        self.feedbackEnabled = feedbackEnabled
        self.requestedLocale = requestedLocale
        self.resolvedLocale = resolvedLocale
        self.baseLocale = baseLocale
        self.availableLocales = availableLocales
        self.supportedLocales = supportedLocales
        self.categories = categories
    }

    public var hasMenuItems: Bool {
        categories.contains { category in
            !category.items.isEmpty
                || category.subcategories.contains { !$0.items.isEmpty }
        }
    }
}

public struct MenuCategory: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let position: Int
    public let items: [MenuItem]
    public let subcategories: [MenuSubcategory]

    public init(
        id: String,
        name: String,
        description: String?,
        position: Int,
        items: [MenuItem],
        subcategories: [MenuSubcategory]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.position = position
        self.items = items
        self.subcategories = subcategories
    }

    /// Items listed on the category itself, excluding those already shown under a subcategory.
    public var directItems: [MenuItem] {
        let subcategoryItemIDs = Set(subcategories.flatMap { $0.items.map(\.id) })
        return items.filter { !subcategoryItemIDs.contains($0.id) }
    }
}

public struct MenuSubcategory: Sendable, Equatable, Identifiable {
    public let id: String
    public let categoryID: String
    public let name: String
    public let description: String?
    public let position: Int
    public let items: [MenuItem]

    public init(
        id: String,
        categoryID: String,
        name: String,
        description: String?,
        position: Int,
        items: [MenuItem]
    ) {
        self.id = id
        self.categoryID = categoryID
        self.name = name
        self.description = description
        self.position = position
        self.items = items
    }
}

public struct MenuItemVariant: Sendable, Equatable, Identifiable {
    public let id: String
    public let label: String
    public let detail: String?
    public let price: String
    public let position: Int

    public init(
        id: String,
        label: String,
        detail: String?,
        price: String,
        position: Int
    ) {
        self.id = id
        self.label = label
        self.detail = detail
        self.price = price
        self.position = position
    }
}

public struct MenuItem: Sendable, Equatable, Identifiable {
    public let id: String
    public let categoryID: String
    public let subcategoryID: String?
    public let name: String
    public let description: String?
    public let ingredients: String?
    public let servingSize: String?
    public let allergens: [String]
    public let price: String
    public let variants: [MenuItemVariant]
    public let dietaryType: DietaryType
    public let position: Int
    public let isAvailable: Bool
    public let imageKey: String?
    public let imageURL: URL?

    public init(
        id: String,
        categoryID: String,
        subcategoryID: String?,
        name: String,
        description: String?,
        ingredients: String?,
        servingSize: String?,
        allergens: [String],
        price: String,
        variants: [MenuItemVariant] = [],
        dietaryType: DietaryType,
        position: Int,
        isAvailable: Bool,
        imageKey: String? = nil,
        imageURL: URL?
    ) {
        self.id = id
        self.categoryID = categoryID
        self.subcategoryID = subcategoryID
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.servingSize = servingSize
        self.allergens = allergens
        self.price = price
        self.variants = variants
        self.dietaryType = dietaryType
        self.position = position
        self.isAvailable = isAvailable
        self.imageKey = imageKey
        self.imageURL = imageURL
    }
}
