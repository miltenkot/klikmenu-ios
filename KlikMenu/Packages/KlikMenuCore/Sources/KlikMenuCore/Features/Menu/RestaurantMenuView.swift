import Observation
import SwiftUI

public struct RestaurantMenuView: View {
    private let slug: String
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
        viewModel: RestaurantMenuViewModel? = nil
    ) {
        self.slug = slug
        _viewModel = State(initialValue: viewModel ?? RestaurantMenuViewModel(api: LiveKlikMenuAPIClient()))
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        Group {
            switch viewModel.state {
            case .loading:
                MenuLoadingView()
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
                        feedRows: viewModel.feedRows,
                        showFeedback: viewModel.showFeedbackButton,
                        showsOrderPanel: showsOrderPanel,
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
        .onChange(of: showsOrderPanel) { _, isVisible in
            if isVisible { showOrderList = false }
        }
        .onChange(of: viewModel.menu?.orderListEnabled) { _, isEnabled in
            if isEnabled != true { showOrderList = false }
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
                slug: presentation.slug,
                config: presentation.config,
                viewModel: presentation.viewModel
            )
        }
        .onChange(of: slug) { _, _ in
            presentedFeedback = nil
            showSearch = false
            showOrderList = false
        }
        .task(id: slug) {
            await viewModel.load(slug: slug)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await viewModel.reloadIfLanguageChanged() }
        }
    }

    private var showsOrderPanel: Bool {
        #if os(iOS)
        if #available(iOS 27.1, *) {
            return horizontalSizeClass == .regular && viewModel.menu?.orderListEnabled == true
        }
        #endif
        return false
    }

    private func retry() {
        Task { await viewModel.retry() }
    }

    private func openFeedback() {
        guard viewModel.state == .loaded,
              viewModel.menu?.slug == slug,
              let config = viewModel.feedbackConfig else { return }
        presentedFeedback = FeedbackPresentation(
            slug: slug,
            config: config,
            viewModel: viewModel.makeFeedbackViewModel()
        )
    }
}

private struct FeedbackPresentation: Identifiable {
    let id = UUID()
    // Keep the destination paired with its configuration while the sheet is presented or dismissing.
    let slug: String
    let config: FeedbackConfig
    let viewModel: FeedbackViewModel
}

#Preview("Loaded") {
    RestaurantMenuView(
        slug: PreviewRestaurantMenu.slug,
        viewModel: RestaurantMenuViewModel(api: PreviewKlikMenuAPIClient())
    )
}

#Preview("Loading") {
    RestaurantMenuView(
        slug: PreviewRestaurantMenu.slug,
        viewModel: RestaurantMenuViewModel(api: PreviewKlikMenuAPIClient(delayNanoseconds: 60_000_000_000))
    )
}

#Preview("Not found") {
    RestaurantMenuView(
        slug: "missing",
        viewModel: RestaurantMenuViewModel(api: PreviewKlikMenuAPIClient(shouldFailAsNotFound: true))
    )
}
