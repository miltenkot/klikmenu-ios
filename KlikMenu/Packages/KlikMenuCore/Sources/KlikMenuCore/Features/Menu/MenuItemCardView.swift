import SwiftUI

public struct MenuItemCardView: View {
    public let item: MenuItem
    public let currency: String

    public init(item: MenuItem, currency: String) {
        self.item = item
        self.currency = currency
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if item.imageURL != nil {
                RemoteImageView(url: item.imageURL, cacheKey: item.imageKey)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                MenuItemCardHeaderView(item: item, currency: currency)

                if !item.variants.isEmpty {
                    MenuItemVariantsListView(item: item, variants: item.variants, currency: currency)
                }

                if item.variants.isEmpty, let servingSize = item.servingSize {
                    Text(servingSize)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.klikMuted)
                }

                MenuItemCardMetadataSectionsView(item: item)
            }
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .contain)
    }
}

private enum MenuItemCardLayout {
    static let postVariantsSpacing: CGFloat = 14
}

private struct MenuItemCardHeaderView: View {
    let item: MenuItem
    let currency: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(Color.klikText)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                MenuItemBadgesView(dietaryType: item.dietaryType, spicinessLevel: item.spicinessLevel)
            }

            if item.variants.isEmpty {
                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 8) {
                    MenuItemPriceText(price: item.price, currency: currency)
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.klikAccent)

                    AddToOrderControlView(item: item, variant: nil)
                }
            }
        }
    }
}

private struct MenuItemCardMetadataSectionsView: View {
    let item: MenuItem

    var body: some View {
        let hasVariants = !item.variants.isEmpty

        if let description = item.description {
            Text(description)
                .font(.subheadline)
                .foregroundStyle(Color.klikMuted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, hasVariants ? MenuItemCardLayout.postVariantsSpacing - 8 : 0)
        }

        if let ingredients = item.ingredients {
            Text("Składniki: \(ingredients)", bundle: #bundle)
                .font(.footnote)
                .foregroundStyle(Color.klikMuted)
                .padding(.top, hasVariants && item.description == nil ? MenuItemCardLayout.postVariantsSpacing - 8 : 0)
        }

        if !item.allergens.isEmpty {
            Label {
                Text("Alergeny: \(allergensText)", bundle: #bundle)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .accessibilityHidden(true)
            }
            .font(.footnote)
            .foregroundStyle(Color.klikAccent)
            .padding(.top, hasVariants && item.description == nil && item.ingredients == nil
                ? MenuItemCardLayout.postVariantsSpacing - 8
                : 0)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Uwaga, alergeny: \(allergensText)", bundle: #bundle))
        }
    }

    private var allergensText: String {
        item.allergens.formatted()
    }
}
