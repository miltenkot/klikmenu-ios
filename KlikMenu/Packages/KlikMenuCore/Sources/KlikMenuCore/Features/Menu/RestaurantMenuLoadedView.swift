import SwiftUI

struct RestaurantMenuLoadedView: View {
    @Environment(OrderListStore.self) private var orderListStore

    let menu: RestaurantMenu
    let feedRows: [MenuFeedRow]
    let showFeedback: Bool
    let showsOrderPanel: Bool
    let topSafeAreaInset: CGFloat
    @Binding var showSearch: Bool
    @Binding var showOrderList: Bool
    let onFeedback: () -> Void
    #if os(iOS)
    @State private var menuScrollPosition = ScrollPosition()
    #endif

    var body: some View {
        #if os(iOS)
        if #available(iOS 27.1, *), showsOrderPanel {
            ArrangementView {
                menuContent(showsFloatingSearch: true)
            } secondary: {
                OrderListPanelView()
                    .splitArrangementLayoutRatio(idealHorizontal: 0.4)
            }
            .arrangementViewStyle(.split)
        } else if #available(iOS 27.1, *) {
            MenuSystemSearchContainer(onSearch: openSearch, onOpenOrderList: { showOrderList = true }) { showsFloatingSearch in
                menuContent(showsFloatingSearch: showsFloatingSearch)
            }
        } else {
            menuContent(showsFloatingSearch: true)
        }
        #else
        menuContent(showsFloatingSearch: true)
        #endif
    }

    private func menuContent(showsFloatingSearch: Bool) -> some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    MenuHeroView(
                        menu: menu,
                        showFeedback: showFeedback,
                        onFeedback: onFeedback,
                        topSafeAreaInset: topSafeAreaInset,
                        extendsBackgroundToScreenEdges: !showsOrderPanel
                    )

                    ForEach(feedRows) { row in
                        MenuFeedRowView(row: row)
                    }
                }
                .padding(.bottom, scrollBottomPadding)
            }
            // Keep scrolling cards in their own accessibility container so their
            // large frames do not compete with the persistent overlay controls.
            .accessibilityElement(children: .contain)
            #if os(iOS)
            .scrollPosition($menuScrollPosition)
            #endif
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .ignoresSafeArea(edges: .top)
            .safeAreaPadding(.bottom, 8)

            RestaurantMenuBottomActionsView(
                showsOrderBar: orderListStore.showsOrderBar && !showsOrderPanel && showsFloatingSearch,
                onOpenOrderList: { showOrderList = true },
                onOpenSearch: openSearch,
                showsFloatingSearch: showsFloatingSearch
            )
            .zIndex(1)
        }
    }

    private var scrollBottomPadding: CGFloat {
        orderListStore.showsOrderBar && !showsOrderPanel ? 168 : 96
    }

    private func openSearch() {
        showSearch = true
    }
}

private struct RestaurantMenuBottomActionsView: View {
    let showsOrderBar: Bool
    let onOpenOrderList: () -> Void
    let onOpenSearch: () -> Void
    let showsFloatingSearch: Bool

    var body: some View {
        VStack(spacing: 8) {
            if showsOrderBar {
                OrderListCircleButton(action: onOpenOrderList)
            }

            if showsFloatingSearch {
                MenuSearchFloatingButton(action: onOpenSearch, size: 44)
            }
        }
        .fixedSize()
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 16)
        .safeAreaPadding(.bottom, 16)
    }
}
