import SwiftUI

struct MenuItemDetailPresentation: ViewModifier {
    @Environment(OrderListStore.self) private var orderListStore
    @State private var isPresented = false
    let item: MenuItem
    let currency: String

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture { isPresented = true }
            .accessibilityAction(named: Text(item.name)) {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                MenuItemDetailSheet(item: item, currency: currency)
                    .environment(orderListStore)
            }
    }
}
