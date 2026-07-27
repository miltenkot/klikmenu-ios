import SwiftUI

public struct MenuCategorySectionView: View {
    public let category: MenuCategory
    public let currency: String

    public init(category: MenuCategory, currency: String) {
        self.category = category
        self.currency = currency
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(category.name)
                    .font(.system(.title, design: .serif).weight(.bold))
                    .foregroundStyle(Color.klikText)
                if let description = category.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color.klikMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(category.directItems) { item in
                    if item.id != category.directItems.first?.id {
                        Divider().overlay { Color.klikBorder.opacity(0.85) }
                    }
                    MenuItemCardView(item: item, currency: currency)
                }

                ForEach(category.subcategories) { subcategory in
                    MenuSubcategorySectionView(subcategory: subcategory, currency: currency)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.klikSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.klikBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.06), radius: 18, y: 8)
        .accessibilityElement(children: .contain)
    }
}
