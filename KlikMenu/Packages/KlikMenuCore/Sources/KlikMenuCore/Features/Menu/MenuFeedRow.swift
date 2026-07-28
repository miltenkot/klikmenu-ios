import Foundation

enum MenuCardEdge: Equatable, Sendable {
    case top
    case middle
    case bottom
    case single
}

enum MenuFeedRow: Identifiable, Equatable, Sendable {
    case categoryHeader(
        id: String,
        name: String,
        description: String?,
        isFirstCategory: Bool,
        edge: MenuCardEdge
    )
    case subcategoryHeader(
        id: String,
        name: String,
        description: String?,
        edge: MenuCardEdge
    )
    case item(
        MenuItem,
        currency: String,
        showsDividerAbove: Bool,
        edge: MenuCardEdge
    )

    var id: String {
        switch self {
        case .categoryHeader(let id, _, _, _, _):
            "category-\(id)"
        case .subcategoryHeader(let id, _, _, _):
            "subcategory-\(id)"
        case .item(let item, _, _, _):
            "item-\(item.id)"
        }
    }

    static func rows(categories: [MenuCategory], currency: String) -> [MenuFeedRow] {
        categories.enumerated().flatMap { categoryIndex, category in
            rows(for: category, currency: currency, isFirstCategory: categoryIndex == 0)
        }
    }

    private static func rows(
        for category: MenuCategory,
        currency: String,
        isFirstCategory: Bool
    ) -> [MenuFeedRow] {
        struct Pending {
            enum Kind {
                case categoryHeader
                case subcategoryHeader(MenuSubcategory)
                case item(MenuItem, showsDividerAbove: Bool)
            }

            let kind: Kind
        }

        var pending: [Pending] = [.init(kind: .categoryHeader)]

        let directItems = category.directItems
        for (index, item) in directItems.enumerated() {
            pending.append(.init(kind: .item(item, showsDividerAbove: index > 0)))
        }

        for subcategory in category.subcategories {
            pending.append(.init(kind: .subcategoryHeader(subcategory)))
            for (index, item) in subcategory.items.enumerated() {
                pending.append(.init(kind: .item(item, showsDividerAbove: index > 0)))
            }
        }

        let edges = cardEdges(count: pending.count)
        return zip(pending, edges).map { entry, edge in
            switch entry.kind {
            case .categoryHeader:
                .categoryHeader(
                    id: category.id,
                    name: category.name,
                    description: category.description,
                    isFirstCategory: isFirstCategory,
                    edge: edge
                )
            case .subcategoryHeader(let subcategory):
                .subcategoryHeader(
                    id: subcategory.id,
                    name: subcategory.name,
                    description: subcategory.description,
                    edge: edge
                )
            case .item(let item, let showsDividerAbove):
                .item(
                    item,
                    currency: currency,
                    showsDividerAbove: showsDividerAbove,
                    edge: edge
                )
            }
        }
    }

    private static func cardEdges(count: Int) -> [MenuCardEdge] {
        guard count > 0 else { return [] }
        guard count > 1 else { return [.single] }
        return (0..<count).map { index in
            if index == 0 { return .top }
            if index == count - 1 { return .bottom }
            return .middle
        }
    }
}
