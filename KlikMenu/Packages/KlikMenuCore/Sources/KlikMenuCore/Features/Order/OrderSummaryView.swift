import SwiftUI

struct OrderSummaryView: View {
    let currency: String
    let productsSubtotal: Decimal
    let serviceCharge: ServiceCharge?
    let serviceChargeAmount: Decimal
    let total: Decimal

    var body: some View {
        VStack(spacing: 10) {
            if serviceCharge != nil {
                OrderSummaryRowView(
                    title: Text("Suma produktów", bundle: #bundle),
                    amount: PriceFormatter.string(decimal: productsSubtotal, currency: currency)
                )
                if let serviceCharge {
                    OrderSummaryRowView(
                        title: serviceChargeSummaryTitle(serviceCharge),
                        amount: PriceFormatter.string(decimal: serviceChargeAmount, currency: currency)
                    )
                }
            }

            OrderSummaryRowView(
                title: Text("Razem", bundle: #bundle),
                amount: PriceFormatter.string(decimal: total, currency: currency),
                isTotal: true
            )
        }
        .padding(.top, 8)
    }

    private func serviceChargeSummaryTitle(_ serviceCharge: ServiceCharge) -> Text {
        if let suffix = OrderListCalculator.percentageSuffix(for: serviceCharge) {
            return Text("\(serviceCharge.label) \(suffix)")
        }
        return Text(verbatim: serviceCharge.label)
    }
}

struct OrderSummaryRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let title: Text
    let amount: String
    var isTotal: Bool = false

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))

        layout {
            title
                .font(isTotal ? .headline : .subheadline)
                .foregroundStyle(Color.klikText)
                .fixedSize(horizontal: false, vertical: true)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 12)
            }
            Text(amount)
                .font(isTotal ? .headline.weight(.bold) : .subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(isTotal ? Color.klikAccent : Color.klikText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
