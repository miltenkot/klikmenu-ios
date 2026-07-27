import Foundation

public enum DietaryFilter: String, CaseIterable, Sendable, Equatable {
    case all = "ALL"
    case vegetarian = "VEGETARIAN"
    case vegan = "VEGAN"
}

public struct MenuFilters: Sendable, Equatable {
    public var query: String = ""
    public var dietaryType: DietaryFilter = .all
    public var categoryID: String?
    public var subcategoryID: String?

    public init(
        query: String = "",
        dietaryType: DietaryFilter = .all,
        categoryID: String? = nil,
        subcategoryID: String? = nil
    ) {
        self.query = query
        self.dietaryType = dietaryType
        self.categoryID = categoryID
        self.subcategoryID = subcategoryID
    }
}

public struct FilteredMenuItem: Sendable, Equatable, Identifiable {
    public var id: String { item.id }
    public let item: MenuItem
    public let subcategoryID: String?
    public let subcategoryName: String?
}

public struct FilteredMenuCategory: Sendable, Equatable, Identifiable {
    public var id: String { category.id }
    public let category: MenuCategory
    public let items: [FilteredMenuItem]
}

public func normalizeMenuSearch(_ value: String) -> String {
    value
        .lowercased(with: Locale(identifier: "pl_PL"))
        .replacing("ł", with: "l")
        .folding(options: .diacriticInsensitive, locale: Locale(identifier: "pl_PL"))
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

public func categorySearchItems(_ category: MenuCategory) -> [FilteredMenuItem] {
    var seen = Set<String>()

    let direct = category.directItems.map {
        FilteredMenuItem(item: $0, subcategoryID: nil, subcategoryName: nil)
    }

    let nested = category.subcategories.flatMap { subcategory in
        subcategory.items.map {
            FilteredMenuItem(
                item: $0,
                subcategoryID: subcategory.id,
                subcategoryName: subcategory.name
            )
        }
    }

    return (direct + nested).filter { entry in
        seen.insert(entry.item.id).inserted
    }
}

public func filterMenuCategories(
    _ categories: [MenuCategory],
    filters: MenuFilters
) -> [FilteredMenuCategory] {
    let query = normalizeMenuSearch(filters.query)

    return categories.compactMap { category in
        if let categoryID = filters.categoryID, category.id != categoryID {
            return nil
        }

        let items = categorySearchItems(category).filter { entry in
            if let subcategoryID = filters.subcategoryID,
                entry.subcategoryID != subcategoryID
            {
                return false
            }

            if !query.isEmpty,
                !normalizeMenuSearch(entry.item.name).localizedStandardContains(query)
            {
                return false
            }

            switch filters.dietaryType {
            case .all:
                return true
            case .vegetarian:
                return entry.item.dietaryType == .vegetarian
            case .vegan:
                return entry.item.dietaryType == .vegan
            }
        }

        guard !items.isEmpty else { return nil }
        return FilteredMenuCategory(category: category, items: items)
    }
}
