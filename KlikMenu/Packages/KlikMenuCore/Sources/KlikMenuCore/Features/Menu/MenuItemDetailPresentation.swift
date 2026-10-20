import SwiftUI

struct MenuItemDetailPresentation: ViewModifier {
    @Environment(OrderListStore.self) private var orderListStore
    @State private var isPresented = false
    let item: MenuItem
    let currency: String

    func body(content: Content) -> some View {
        content
            .background {
                // A sibling button handles the card's unoccupied area without
                // turning each text fragment or the order controls into a button.
                Button {
                    isPresented = true
                } label: {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(item.name))
                .accessibilityInputLabels([Text(item.name)])
                .accessibilityIdentifier("menuItemDetailsButton")
            }
            .accessibilityElement(children: .contain)
            .sheet(isPresented: $isPresented) {
                MenuItemDetailSheet(item: item, currency: currency)
                    .environment(orderListStore)
            }
    }
}
