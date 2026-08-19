import SwiftUI

struct MenuItemVariantsListView: View {
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

struct MenuItemVariantRowView: View {
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
