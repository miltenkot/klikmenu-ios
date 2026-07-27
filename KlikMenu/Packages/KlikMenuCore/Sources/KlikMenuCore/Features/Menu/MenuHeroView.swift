import SwiftUI

public struct MenuHeroView: View {
    public let menu: RestaurantMenu
    public let showFeedback: Bool
    public let onFeedback: () -> Void
    public var topSafeAreaInset: CGFloat = 0

    public init(
        menu: RestaurantMenu,
        showFeedback: Bool,
        onFeedback: @escaping () -> Void,
        topSafeAreaInset: CGFloat = 0
    ) {
        self.menu = menu
        self.showFeedback = showFeedback
        self.onFeedback = onFeedback
        self.topSafeAreaInset = topSafeAreaInset
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            MenuHeroBackground(heroImageURL: menu.heroImageURL)
            MenuHeroOverlay(showsGradient: menu.heroImageURL != nil)
            MenuHeroContent(
                name: menu.name,
                description: menu.description,
                showFeedback: showFeedback,
                onFeedback: onFeedback,
                topSafeAreaInset: topSafeAreaInset
            )
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 300)
        .clipped()
        .accessibilityElement(children: .contain)
    }
}

private struct MenuHeroBackground: View {
    let heroImageURL: URL?

    var body: some View {
        Group {
            if heroImageURL != nil {
                Color.clear
                    .overlay {
                        RemoteImageView(url: heroImageURL)
                    }
                    .clipped()
            } else {
                Color.klikHero
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

private struct MenuHeroOverlay: View {
    let showsGradient: Bool

    var body: some View {
        if showsGradient {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.72),
                    Color.black.opacity(0.45),
                    Color.black.opacity(0.78),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.clear
        }
    }
}

private struct MenuHeroContent: View {
    let name: String
    let description: String?
    let showFeedback: Bool
    let onFeedback: () -> Void
    let topSafeAreaInset: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MenuHeroTopBar(showFeedback: showFeedback, onFeedback: onFeedback)

            Text(name)
                .font(.system(.largeTitle, design: .serif).weight(.bold))
                .foregroundStyle(Color.klikHeroText)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            if let description {
                Text(description)
                    .font(.body)
                    .foregroundStyle(Color.klikHeroMuted)
                    .lineLimit(4)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        // ScrollView uses ignoresSafeArea(.top), so inset must be applied manually.
        .padding(
            .top,
            (topSafeAreaInset > 0 ? topSafeAreaInset : LayoutMetrics.fallbackTopSafeAreaInset) + 10
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 52)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct MenuHeroTopBar: View {
    let showFeedback: Bool
    let onFeedback: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("KLIKMENU", bundle: #bundle)
                .font(.caption.weight(.bold))
                .tracking(2.2)
                .foregroundStyle(Color.klikAccent)
                .lineLimit(1)
                .layoutPriority(1)
                .accessibilityLabel(Text("KlikMenu", bundle: #bundle))

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                if showFeedback {
                    ViewThatFits(in: .horizontal) {
                        FeedbackActionButton(compact: false, action: onFeedback)
                        FeedbackActionButton(compact: true, action: onFeedback)
                    }
                }

                ThemeSwitcherControl()
                    .foregroundStyle(Color.klikText)
                    .background {
                        Circle()
                            .fill(Color.klikSurface.opacity(0.92))
                    }
            }
            .layoutPriority(2)
        }
        .frame(maxWidth: .infinity)
    }
}
