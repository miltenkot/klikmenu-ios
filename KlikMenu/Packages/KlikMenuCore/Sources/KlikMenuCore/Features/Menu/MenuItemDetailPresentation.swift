import SwiftUI

struct MenuItemDetailPresentation: ViewModifier {
    @Environment(OrderListStore.self) private var orderListStore
    @State private var isPresented = false
    let item: MenuItem
    let currency: String

    func body(content: Content) -> some View {
        Button {
            isPresented = true
        } label: {
            content
                .contentShape(Rectangle())
        }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(item.name))
            .accessibilityInputLabels([Text(item.name)])
            .accessibilityIdentifier("menuItemDetailsButton")
            .sheet(isPresented: $isPresented) {
                MenuItemDetailSheet(item: item, currency: currency)
                    .environment(orderListStore)
            }
    }
}
