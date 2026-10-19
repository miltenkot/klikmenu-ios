import SwiftUI

#if os(iOS)
@available(iOS 27.1, *)
struct MenuSystemSearchContainer<Content: View>: View {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
    @Environment(OrderListStore.self) private var orderListStore

    let onSearch: () -> Void
    let onOpenOrderList: () -> Void
    @ViewBuilder let content: (Bool) -> Content

    var body: some View {
        // Other iPhones retain the existing floating buttons and layout.
        if toolbarVerticalEdge != nil {
            NavigationStack {
                content(false)
                    .toolbar {
                        if orderListStore.showsOrderBar {
                            ToolbarItem(placement: .bottomBar) {
                                OrderListCircleButton(action: onOpenOrderList)
                            }
                            .axisBehavior(.verticalPreferred)
                            .sharedBackgroundVisibility(.hidden)

                            ToolbarSpacer(.fixed, placement: .bottomBar)
                        }
                        ToolbarItem(placement: .bottomBar) {
                            Button(action: onSearch) {
                                Label {
                                    Text("Przeglądaj i wyszukaj menu", bundle: #bundle)
                                } icon: {
                                    Image(systemName: "magnifyingglass")
                                }
                            }
                            .tint(Color.klikAccent)
                            .accessibilityIdentifier("menuSystemSearch")
                        }
                    }
            }
        } else {
            content(true)
        }
    }
}
#endif
