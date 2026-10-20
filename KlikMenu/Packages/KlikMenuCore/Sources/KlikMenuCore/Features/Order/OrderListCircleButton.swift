import SwiftUI

struct OrderListCircleButton: View {
    @Environment(OrderListStore.self) private var orderListStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var scaledButtonSize: CGFloat = 44
    @ScaledMetric(relativeTo: .caption2) private var badgeTopInset: CGFloat = 10
    let action: () -> Void

    private var buttonSize: CGFloat { max(44, scaledButtonSize) }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title3)
                    .foregroundStyle(Color.klikAccent)
                    .frame(width: buttonSize, height: buttonSize)
                    .background {
                        // Glass is decoration; the enclosing Button owns accessibility.
                        Circle()
                            .fill(.clear)
                            .modifier(MenuCircleButtonBackground())
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    .padding(6)
                    // Reserve space above the circle for a fully scaled counter.
                    .padding(.top, dynamicTypeSize.isAccessibilitySize && orderListStore.totalQuantity > 0
                        ? badgeTopInset : 0)

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
        .accessibilityRespondsToUserInteraction(true)
        .accessibilitySortPriority(1)
        .accessibilityInputLabels([Text("Twoje zamówienie", bundle: #bundle)])
        .accessibilityLabel(Text(
            "Twoje zamówienie, \(orderListStore.totalQuantity), \(PriceFormatter.string(decimal: orderListStore.total, currency: orderListStore.currency))",
            bundle: #bundle
        ))
        .accessibilityIdentifier("orderListCircleButton")
    }
}
