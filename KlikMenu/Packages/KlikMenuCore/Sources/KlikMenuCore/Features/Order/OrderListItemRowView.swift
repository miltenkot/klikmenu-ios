import SwiftUI

struct OrderListItemRowView: View {
    @Environment(OrderListStore.self) private var orderListStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: OrderListItem

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))

        VStack(alignment: .leading, spacing: 10) {
            layout {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.menuItemName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.klikText)
                        .fixedSize(horizontal: false, vertical: true)

                    if let variantLabel = item.variantLabel {
                        Text(variantLabel)
                            .font(.subheadline)
                            .foregroundStyle(Color.klikText)
                    }

                    if let variantDetail = item.variantDetail {
                        Text(variantDetail)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.klikMuted)
                    }

                    Text(PriceFormatter.string(price: item.unitPrice, currency: item.currency))
                        .font(.footnote)
                        .foregroundStyle(Color.klikMuted)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(itemAccessibilityLabel))

                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer(minLength: 8)
                }

                VStack(alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .trailing, spacing: 8) {
                    Text(PriceFormatter.string(decimal: item.lineSubtotal, currency: item.currency))
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.klikAccent)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(Text("Suma pozycji \(lineSubtotalText)", bundle: #bundle))

                    OrderQuantityStepperView(
                        quantity: item.quantity,
                        accessibilityName: accessibilityName,
                        onDecrease: { orderListStore.decrement(lineKey: item.id) },
                        onIncrease: { orderListStore.increment(lineKey: item.id) }
                    )
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }

    private var accessibilityName: String {
        if let variantLabel = item.variantLabel {
            if let variantDetail = item.variantDetail, !variantDetail.isEmpty {
                return "\(item.menuItemName), \(variantLabel), \(variantDetail)"
            }
            return "\(item.menuItemName), \(variantLabel)"
        }
        return item.menuItemName
    }

    private var itemAccessibilityLabel: String {
        var parts = [accessibilityName]
        parts.append(String(localized: "Cena jednostkowa \(unitPriceText)", bundle: #bundle))
        parts.append(String(localized: "Ilość \(item.quantity)", bundle: #bundle))
        parts.append(String(localized: "Suma pozycji \(lineSubtotalText)", bundle: #bundle))
        return parts.joined(separator: ", ")
    }

    private var unitPriceText: String {
        PriceFormatter.string(price: item.unitPrice, currency: item.currency)
    }

    private var lineSubtotalText: String {
        PriceFormatter.string(decimal: item.lineSubtotal, currency: item.currency)
    }
}
