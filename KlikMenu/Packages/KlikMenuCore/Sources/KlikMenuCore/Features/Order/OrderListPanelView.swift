import SwiftUI

struct OrderListPanelView: View {
    @Environment(OrderListStore.self) private var orderListStore

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Twoje zamówienie", bundle: #bundle)
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                if !orderListStore.items.isEmpty {
                    Button(LocalizedStringResource("Wyczyść", bundle: #bundle)) {
                        orderListStore.clear()
                    }
                    .font(.body.weight(.semibold))
                    .tint(Color.klikAccent)
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .padding()
            Divider()
            OrderListContentView()
                .contentMargins(.leading, 12, for: .scrollContent)
        }
        .background(Color.klikPageBackground)
        .accessibilityIdentifier("orderListPanel")
    }
}
