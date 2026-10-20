import SwiftUI

struct OrderListCircleButton: View {
    @Environment(OrderListStore.self) private var orderListStore
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title3)
                    .foregroundStyle(Color.klikAccent)
                    .frame(width: 44, height: 44)
                    .modifier(MenuCircleButtonBackground())
                    .padding(6)

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
                        .accessibilityHidden(true)
                }
            }
            .fixedSize()
            // Keep the counter and transparent margin inside the same touch target.
            .contentShape(.interaction, Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(
            "Twoje zamówienie, \(orderListStore.totalQuantity), \(PriceFormatter.string(decimal: orderListStore.total, currency: orderListStore.currency))",
            bundle: #bundle
        ))
        .accessibilityIdentifier("orderListCircleButton")
    }
}
