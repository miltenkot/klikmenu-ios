import Observation
import SwiftUI

public struct RestaurantMenuView: View {
    private let slug: String
    @State private var viewModel: RestaurantMenuViewModel
    @State private var showSearch = false
    @State private var showFeedback = false
    /// Dynamic Island / notch inset; start at 59 so the first frame is already below the island.
    @State private var topSafeAreaInset: CGFloat = 59

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
                MenuErrorView(message: "Nie znaleziono restauracji.") {
                    Task { await viewModel.retry() }
                }
            case .error(let message):
                MenuErrorView(message: message) {
                    Task { await viewModel.retry() }
                }
            case .loaded:
                if let menu = viewModel.menu {
                    loadedContent(menu: menu, viewModel: viewModel)
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

    @ViewBuilder
    private func loadedContent(
        menu: RestaurantMenu,
        viewModel: RestaurantMenuViewModel
    ) -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                    MenuHeroView(
                        menu: menu,
                        showFeedback: viewModel.showFeedbackButton,
                        onFeedback: { showFeedback = true },
                        topSafeAreaInset: topSafeAreaInset
                    )

                    LazyVStack(alignment: .leading, spacing: 18) {
                        ForEach(menu.categories) { category in
                            MenuCategorySectionView(category: category, currency: menu.currency)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 96)
                    .padding(.top, 12)
                    .offset(y: -24)
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .safeAreaPadding(.bottom, 8)

            MenuSearchFloatingButton {
                showSearch = true
            }
            .padding(.trailing, 16)
            .safeAreaPadding(.bottom, 16)
            .accessibilityLabel("Przeglądaj i wyszukaj menu")
            .accessibilityHint("Otwiera natywne wyszukiwanie i filtry")
        }
        .sheet(isPresented: $showSearch) {
            MenuSearchSheet(menu: menu)
        }
        .sheet(isPresented: $showFeedback) {
            if let config = viewModel.feedbackConfig {
                ServiceFeedbackSheet(
                    slug: slug,
                    config: config,
                    viewModel: viewModel.makeFeedbackViewModel()
                )
            }
        }
    }
}

private struct MenuSearchFloatingButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.klikHeroText)
                .frame(width: 60, height: 60)
                .background(Color.klikAccent, in: Circle())
                .overlay(
                    Circle()
                        .stroke(Color.klikHeroText, lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.22), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
    }
}
