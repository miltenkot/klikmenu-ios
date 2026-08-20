import SwiftUI

struct OrderListItemRowView: View {
    @Environment(OrderListStore.self) private var orderListStore

    let item: OrderListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
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

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 8) {
                    Text(PriceFormatter.string(decimal: item.lineSubtotal, currency: item.currency))
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.klikAccent)
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
        parts.append("Cena jednostkowa \(PriceFormatter.string(price: item.unitPrice, currency: item.currency))")
        parts.append("Ilość \(item.quantity)")
        parts.append("Suma pozycji \(lineSubtotalText)")
        return parts.joined(separator: ", ")
    }

    private var lineSubtotalText: String {
        PriceFormatter.string(decimal: item.lineSubtotal, currency: item.currency)
    }
}
