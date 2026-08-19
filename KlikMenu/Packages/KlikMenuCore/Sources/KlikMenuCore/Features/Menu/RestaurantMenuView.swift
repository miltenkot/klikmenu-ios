import Observation
import SwiftUI

public struct RestaurantMenuView: View {
    private let slug: String
    private let onOrderBarVisibilityChanged: ((Bool) -> Void)?
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: RestaurantMenuViewModel
    @State private var orderListStore = OrderListStore()
    @State private var showSearch = false
    @State private var showOrderList = false
    @State private var presentedFeedback: FeedbackPresentation?
    /// Dynamic Island / notch inset; start with fallback so the first frame is already below the island.
    @State private var topSafeAreaInset = LayoutMetrics.fallbackTopSafeAreaInset

    public init(
        slug: String,
        viewModel: RestaurantMenuViewModel? = nil,
        onOrderBarVisibilityChanged: ((Bool) -> Void)? = nil
    ) {
        self.slug = slug
        self.onOrderBarVisibilityChanged = onOrderBarVisibilityChanged
        _viewModel = State(initialValue: viewModel ?? RestaurantMenuViewModel(api: LiveKlikMenuAPIClient()))
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        Group {
            switch viewModel.state {
            case .loading:
                MenuLoadingView(topSafeAreaInset: topSafeAreaInset)
            case .empty:
                EmptyMenuView()
            case .notFound:
                MenuErrorView(
                    message: LocalizedStringResource("Nie znaleziono restauracji.", bundle: #bundle),
                    retry: retry
                )
            case .error(let message):
                MenuErrorView(message: message, retry: retry)
            case .loaded:
                if let menu = viewModel.menu {
                    RestaurantMenuLoadedView(
                        menu: menu,
                        showFeedback: viewModel.showFeedbackButton,
                        topSafeAreaInset: topSafeAreaInset,
                        showSearch: $showSearch,
                        showOrderList: $showOrderList,
                        onFeedback: openFeedback
                    )
                }
            }
        }
        .environment(orderListStore)
        .task(id: viewModel.menu?.id) {
            if let menu = viewModel.menu {
                orderListStore.configure(menu: menu)
            }
        }
        .onChange(of: orderListStore.showsOrderBar) { _, isVisible in
            onOrderBarVisibilityChanged?(isVisible)
        }
        .background { Color.klikPageBackground.ignoresSafeArea() }
        .background {
            WindowSafeAreaTopReader(topInset: $topSafeAreaInset)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .klikMenuPreferredColorScheme()
        .sheet(isPresented: $showSearch) {
            if let menu = viewModel.menu {
                MenuSearchSheet(menu: menu)
                    .environment(orderListStore)
            }
        }
        .sheet(isPresented: $showOrderList) {
            OrderListSheetView()
                .environment(orderListStore)
        }
        .sheet(item: $presentedFeedback) { presentation in
            ServiceFeedbackSheet(
                slug: slug,
                config: presentation.config,
                viewModel: presentation.viewModel
            )
        }
        .task(id: slug) {
            await viewModel.load(slug: slug)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await viewModel.reloadIfLanguageChanged() }
        }
        .onDisappear {
            onOrderBarVisibilityChanged?(false)
        }
    }

    private func retry() {
        Task { await viewModel.retry() }
    }

    private func openFeedback() {
        guard let config = viewModel.feedbackConfig else { return }
        presentedFeedback = FeedbackPresentation(
            config: config,
            viewModel: viewModel.makeFeedbackViewModel()
        )
    }
}

private struct FeedbackPresentation: Identifiable {
    var id: String { config.id }
    let config: FeedbackConfig
    let viewModel: FeedbackViewModel
}

private struct RestaurantMenuLoadedView: View {
    @Environment(OrderListStore.self) private var orderListStore

    let menu: RestaurantMenu
    let showFeedback: Bool
    let topSafeAreaInset: CGFloat
    @Binding var showSearch: Bool
    @Binding var showOrderList: Bool
    let onFeedback: () -> Void
    private let feedRows: [MenuFeedRow]

    init(
        menu: RestaurantMenu,
        showFeedback: Bool,
        topSafeAreaInset: CGFloat,
        showSearch: Binding<Bool>,
        showOrderList: Binding<Bool>,
        onFeedback: @escaping () -> Void
    ) {
        self.menu = menu
        self.showFeedback = showFeedback
        self.topSafeAreaInset = topSafeAreaInset
        _showSearch = showSearch
        _showOrderList = showOrderList
        self.onFeedback = onFeedback
        feedRows = MenuFeedRow.rows(categories: menu.categories, currency: menu.currency)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    MenuHeroView(
                        menu: menu,
                        showFeedback: showFeedback,
                        onFeedback: onFeedback,
                        topSafeAreaInset: topSafeAreaInset
                    )

                    ForEach(feedRows) { row in
                        MenuFeedRowView(row: row)
                    }
                }
                .padding(.bottom, scrollBottomPadding)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .safeAreaPadding(.bottom, 8)

            RestaurantMenuBottomActionsView(
                showsOrderBar: orderListStore.showsOrderBar,
                orderQuantity: orderListStore.totalQuantity,
                orderTotalText: PriceFormatter.string(decimal: orderListStore.total, currency: orderListStore.currency),
                onOpenOrderList: { showOrderList = true },
                onOpenSearch: openSearch
            )
        }
    }

    private var scrollBottomPadding: CGFloat {
        orderListStore.showsOrderBar ? 168 : 96
    }

    private func openSearch() {
        showSearch = true
    }
}

private struct RestaurantMenuBottomActionsView: View {
    let showsOrderBar: Bool
    let orderQuantity: Int
    let orderTotalText: String
    let onOpenOrderList: () -> Void
    let onOpenSearch: () -> Void
    private let controlHeight: CGFloat = 56

    var body: some View {
        HStack(spacing: 12) {
            if showsOrderBar {
                OrderListBarButton(
                    quantity: orderQuantity,
                    totalText: orderTotalText,
                    action: onOpenOrderList,
                    height: controlHeight
                )
            } else {
                Spacer(minLength: 0)
            }

            MenuSearchFloatingButton(
                action: onOpenSearch,
                size: controlHeight
            )
        }
        .padding(.horizontal, 16)
        .safeAreaPadding(.bottom, 16)
    }
}
