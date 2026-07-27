import Foundation

public struct PublicMenuResponseDTO: Decodable, Sendable {
    public let data: RestaurantDTO
}

public struct RestaurantDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String?
    public let address: String?
    public let phone: String?
    public let currency: String
    public let isPublished: Bool
    public let feedbackEnabled: Bool
    public let createdAt: String
    public let updatedAt: String
    public let heroImageUrl: String?
    public let categories: [MenuCategoryDTO]

    private enum CodingKeys: String, CodingKey {
        case id, name, slug, description, address, phone, currency
        case isPublished, feedbackEnabled, createdAt, updatedAt, heroImageUrl, categories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? "PLN"
        isPublished = try container.decodeIfPresent(Bool.self, forKey: .isPublished) ?? false
        feedbackEnabled = try container.decodeIfPresent(Bool.self, forKey: .feedbackEnabled) ?? false
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        heroImageUrl = try container.decodeIfPresent(String.self, forKey: .heroImageUrl)
        categories = try container.decodeIfPresent([MenuCategoryDTO].self, forKey: .categories) ?? []
    }
}

public struct MenuCategoryDTO: Decodable, Sendable {
    public let id: String
    public let restaurantId: String
    public let name: String
    public let description: String?
    public let position: Int
    public let isVisible: Bool
    public let createdAt: String
    public let updatedAt: String
    public let items: [MenuItemDTO]
    public let subcategories: [MenuSubcategoryDTO]

    private enum CodingKeys: String, CodingKey {
        case id, restaurantId, name, description, position, isVisible
        case createdAt, updatedAt, items, subcategories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
        isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        items = try container.decodeIfPresent([MenuItemDTO].self, forKey: .items) ?? []
        subcategories = try container.decodeIfPresent([MenuSubcategoryDTO].self, forKey: .subcategories) ?? []
    }
}

public struct MenuSubcategoryDTO: Decodable, Sendable {
    public let id: String
    public let categoryId: String
    public let name: String
    public let description: String?
    public let position: Int
    public let isVisible: Bool
    public let createdAt: String
    public let updatedAt: String
    public let items: [MenuItemDTO]

    private enum CodingKeys: String, CodingKey {
        case id, categoryId, name, description, position, isVisible
        case createdAt, updatedAt, items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
        isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        items = try container.decodeIfPresent([MenuItemDTO].self, forKey: .items) ?? []
    }
}

public struct MenuItemDTO: Decodable, Sendable {
    public let id: String
    public let categoryId: String
    public let name: String
    public let description: String?
    public let ingredients: String?
    public let servingSize: String?
    public let subcategoryId: String?
    public let allergens: [String]
    public let price: String
    public let dietaryType: String
    public let position: Int
    public let isAvailable: Bool
    public let isVisible: Bool
    public let imageUrl: String?
    public let createdAt: String
    public let updatedAt: String

    private enum CodingKeys: String, CodingKey {
        case id, categoryId, name, description, ingredients, servingSize, subcategoryId
        case allergens, price, dietaryType, position, isAvailable, isVisible, imageUrl
        case createdAt, updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        ingredients = try container.decodeIfPresent(String.self, forKey: .ingredients)
        servingSize = try container.decodeIfPresent(String.self, forKey: .servingSize)
        subcategoryId = try container.decodeIfPresent(String.self, forKey: .subcategoryId)
        allergens = try container.decodeIfPresent([String].self, forKey: .allergens) ?? []
        price = try container.decode(String.self, forKey: .price)
        dietaryType = try container.decodeIfPresent(String.self, forKey: .dietaryType) ?? "NONE"
        position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
        isAvailable = try container.decodeIfPresent(Bool.self, forKey: .isAvailable) ?? true
        isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}
