import SwiftUI

struct MenuItemVariantsListView: View {
    let item: MenuItem
    let variants: [MenuItemVariant]
    let currency: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(variants) { variant in
                MenuItemVariantRowView(item: item, variant: variant, currency: currency)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

struct MenuItemVariantRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let item: MenuItem
    let variant: MenuItemVariant
    let currency: String

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))

        layout {
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

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 8)
            }

            VStack(alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .trailing, spacing: 8) {
                MenuItemPriceText(price: variant.price, currency: currency)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(Color.klikAccent)
                    .layoutPriority(1)

                AddToOrderControlView(item: item, variant: variant)
            }
        }
        .accessibilityElement(children: .contain)
    }
}
