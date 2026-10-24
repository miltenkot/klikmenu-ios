import SwiftUI

struct MenuItemDetailPresentation: ViewModifier {
    @Environment(OrderListStore.self) private var orderListStore
    @State private var isPresented = false
    let item: MenuItem
    let currency: String
    var isCardContainer = false

    func body(content: Content) -> some View {
        Group {
            if isCardContainer {
                // The visible title supplies the accessible button. This gesture
                // also opens details from the rest of the card, outside order controls.
                content
                    .contentShape(.rect)
                    .onTapGesture {
                        isPresented = true
                    }
            } else {
                Button {
                    isPresented = true
                } label: {
                    content
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(item.name))
                .accessibilityInputLabels([Text(item.name)])
                .accessibilityIdentifier("menuItemDetailsButton")
            }
        }
        .sheet(isPresented: $isPresented) {
            MenuItemDetailSheet(item: item, currency: currency)
                .environment(orderListStore)
        }
    }
}
