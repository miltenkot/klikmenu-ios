import Observation
import SwiftUI

public struct RestaurantMenuView: View {
    private let slug: String
    @State private var viewModel: RestaurantMenuViewModel
    @State private var showSearch = false
    @State private var presentedFeedbackConfig: FeedbackConfig?
    /// Dynamic Island / notch inset; start with fallback so the first frame is already below the island.
    @State private var topSafeAreaInset = LayoutMetrics.fallbackTopSafeAreaInset

    public init(slug: String, viewModel: RestaurantMenuViewModel? = nil) {
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
                MenuErrorView(message: "Nie znaleziono restauracji.", retry: retry)
            case .error(let message):
                MenuErrorView(message: message, retry: retry)
            case .loaded:
                if let menu = viewModel.menu {
                    RestaurantMenuLoadedView(
                        menu: menu,
                        slug: slug,
                        showFeedback: viewModel.showFeedbackButton,
                        feedbackConfig: viewModel.feedbackConfig,
                        topSafeAreaInset: topSafeAreaInset,
                        showSearch: $showSearch,
                        presentedFeedbackConfig: $presentedFeedbackConfig,
                        makeFeedbackViewModel: viewModel.makeFeedbackViewModel
                    )
                }
            }
        }
        .background(Color.klikPageBackground.ignoresSafeArea())
        .background {
            WindowSafeAreaTopReader(topInset: $topSafeAreaInset)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .klikMenuPreferredColorScheme()
        .task(id: slug) {
            await viewModel.load(slug: slug)
        }
    }

    private func retry() {
        Task { await viewModel.retry() }
    }
}

private struct RestaurantMenuLoadedView: View {
    let menu: RestaurantMenu
    let slug: String
    let showFeedback: Bool
    let feedbackConfig: FeedbackConfig?
    let topSafeAreaInset: CGFloat
    @Binding var showSearch: Bool
    @Binding var presentedFeedbackConfig: FeedbackConfig?
    let makeFeedbackViewModel: () -> FeedbackViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    MenuHeroView(
                        menu: menu,
                        showFeedback: showFeedback,
                        onFeedback: openFeedback,
                        topSafeAreaInset: topSafeAreaInset
                    )

                    ForEach(Array(menu.categories.enumerated()), id: \.element.id) { index, category in
                        MenuCategorySectionView(category: category, currency: menu.currency)
                            .padding(.horizontal, 16)
                            // Match previous group padding(top: 12) + offset(y: -24).
                            .padding(.top, index == 0 ? -12 : 18)
                    }
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .safeAreaPadding(.bottom, 8)

            MenuSearchFloatingButton(action: openSearch)
                .padding(.trailing, 16)
                .safeAreaPadding(.bottom, 16)
        }
        .sheet(isPresented: $showSearch) {
            MenuSearchSheet(menu: menu)
        }
        .sheet(item: $presentedFeedbackConfig) { config in
            ServiceFeedbackSheet(
                slug: slug,
                config: config,
                viewModel: makeFeedbackViewModel()
            )
        }
    }

    private func openSearch() {
        showSearch = true
    }

    private func openFeedback() {
        presentedFeedbackConfig = feedbackConfig
    }
}
