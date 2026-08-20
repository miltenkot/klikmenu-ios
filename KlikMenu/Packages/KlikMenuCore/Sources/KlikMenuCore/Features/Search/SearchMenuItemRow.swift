import SwiftUI

struct SearchMenuItemRow: View {
    let item: MenuItem
    let currency: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SearchMenuItemHeaderView(item: item, currency: currency)

            if !item.variants.isEmpty {
                MenuItemVariantsListView(item: item, variants: item.variants, currency: currency)
            } else if let servingSize = item.servingSize {
                Text(servingSize)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if item.description != nil || item.ingredients != nil || !item.allergens.isEmpty {
                SearchMenuItemMetadataView(item: item)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct SearchMenuItemHeaderView: View {
    let item: MenuItem
    let currency: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.klikText)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                MenuItemBadgesView(dietaryType: item.dietaryType, spicinessLevel: item.spicinessLevel)
            }

            if item.variants.isEmpty {
                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 8) {
                    MenuItemPriceText(price: item.price, currency: currency)
                        .font(.subheadline.weight(.medium))
                        .monospacedDigit()
                        .foregroundStyle(Color.klikAccent)
                        .layoutPriority(1)

                    AddToOrderControlView(item: item, variant: nil)
                }
            }
        }
    }
}

private struct SearchMenuItemMetadataView: View {
    let item: MenuItem

    var body: some View {
        MenuItemMetadataSectionsView(item: item, usesSecondaryForeground: true)
    }
}
