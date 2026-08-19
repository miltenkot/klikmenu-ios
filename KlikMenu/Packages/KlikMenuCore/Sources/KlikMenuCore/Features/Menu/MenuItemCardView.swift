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
                RemoteImageView(url: item.imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                MenuItemCardHeaderView(item: item, currency: currency)

                if !item.variants.isEmpty {
                    MenuItemVariantsListView(variants: item.variants, currency: currency)
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
        .accessibilityElement(children: .combine)
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

                if let dietaryLabel = item.dietaryType.displayLabel {
                    Text(dietaryLabel)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.klikDietaryBackground, in: Capsule())
                        .overlay {
                            Capsule().stroke(Color.klikDietaryBorder, lineWidth: 1)
                        }
                        .foregroundStyle(Color.klikDietaryText)
                        .accessibilityLabel(Text(dietaryLabel))
                }
            }

            if item.variants.isEmpty {
                Spacer(minLength: 8)

                MenuItemPriceText(price: item.price, currency: currency)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(Color.klikAccent)
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
            Text("Alergeny: \(item.allergens.formatted())", bundle: #bundle)
                .font(.footnote)
                .foregroundStyle(Color.klikMuted)
                .padding(.top, hasVariants && item.description == nil && item.ingredients == nil
                    ? MenuItemCardLayout.postVariantsSpacing - 8
                    : 0)
        }
    }
}

private struct MenuItemVariantsListView: View {
    let variants: [MenuItemVariant]
    let currency: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(variants) { variant in
                MenuItemVariantRowView(variant: variant, currency: currency)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct MenuItemVariantRowView: View {
    let variant: MenuItemVariant
    let currency: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(variant.label)
                    .font(.subheadline)
                    .foregroundStyle(Color.klikText)
                    .fixedSize(horizontal: false, vertical: true)

                if let detail = variant.detail {
                    Text(detail)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.klikMuted)
                }
            }

            Spacer(minLength: 8)

            MenuItemPriceText(price: variant.price, currency: currency)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Color.klikAccent)
                .layoutPriority(1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MenuItemPriceText: View {
    let price: String
    let currency: String

    var body: some View {
        if let value = Decimal(string: price, locale: Locale(identifier: "en_US_POSIX")) {
            Text(value, format: .currency(code: currency))
        } else {
            Text(verbatim: "\(price) \(currency)")
        }
    }
}
