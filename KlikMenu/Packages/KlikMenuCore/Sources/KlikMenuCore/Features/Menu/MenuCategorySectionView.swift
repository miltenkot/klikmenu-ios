import SwiftUI

public struct MenuCategorySectionView: View {
    public let category: MenuCategory
    public let currency: String

    public init(category: MenuCategory, currency: String) {
        self.category = category
        self.currency = currency
    }

    public var body: some View {
        let subcategoryItemIDs = Set(category.subcategories.flatMap { $0.items.map(\.id) })
        let directItems = category.items.filter { !subcategoryItemIDs.contains($0.id) }

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
                ForEach(Array(directItems.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Divider().overlay(Color.klikBorder.opacity(0.85))
                    }
                    MenuItemCardView(item: item, currency: currency)
                }

                ForEach(category.subcategories) { subcategory in
                    subcategorySection(subcategory)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.klikSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.klikBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 18, y: 8)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func subcategorySection(_ subcategory: MenuSubcategory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .overlay(Color.klikBorder)
                .padding(.top, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(subcategory.name)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(Color.klikText)
                if let description = subcategory.description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(Color.klikMuted)
                }
            }
            .padding(.vertical, 12)

            ForEach(Array(subcategory.items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider().overlay(Color.klikBorder.opacity(0.85))
                }
                MenuItemCardView(item: item, currency: currency)
            }
        }
    }
}
