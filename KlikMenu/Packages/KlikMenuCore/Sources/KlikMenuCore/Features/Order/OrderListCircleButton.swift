import SwiftUI

#if os(iOS)
@available(iOS 27.1, *)
struct OrderListCircleButton: View {
    @Environment(OrderListStore.self) private var orderListStore
    let action: () -> Void

    var body: some View {
        // A custom toolbar view keeps the button and counter in one SwiftUI hierarchy.
        ZStack(alignment: .topTrailing) {
            Button(action: action) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title3)
                    .foregroundStyle(Color.klikAccent)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: Circle())
            .padding(6)
            .accessibilityLabel(Text(
                "Twoje zamówienie, \(orderListStore.totalQuantity), \(PriceFormatter.string(decimal: orderListStore.total, currency: orderListStore.currency))",
                bundle: #bundle
            ))
            .accessibilityIdentifier("orderListCircleButton")

            if orderListStore.totalQuantity > 0 {
                Text(orderListStore.totalQuantity, format: .number)
                    .font(.caption2.bold())
                    .monospacedDigit()
                    .padding(.horizontal, 5)
                    .frame(minWidth: 20, minHeight: 20)
                    .foregroundStyle(.white)
                    .background(Color.klikAccent, in: Capsule())
                    .overlay {
                        Capsule().stroke(Color.klikSurface, lineWidth: 2)
                    }
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .fixedSize()
    }
}
#endif
