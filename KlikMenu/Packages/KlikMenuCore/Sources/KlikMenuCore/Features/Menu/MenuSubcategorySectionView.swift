import SwiftUI

struct MenuSubcategorySectionView: View {
    let subcategory: MenuSubcategory
    let currency: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .overlay { Color.klikBorder }
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

            ForEach(subcategory.items) { item in
                if item.id != subcategory.items.first?.id {
                    Divider().overlay { Color.klikBorder.opacity(0.85) }
                }
                MenuItemCardView(item: item, currency: currency)
            }
        }
    }
}
