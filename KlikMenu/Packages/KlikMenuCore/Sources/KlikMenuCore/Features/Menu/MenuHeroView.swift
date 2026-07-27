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
            heroBackground
            heroOverlay
            heroContent
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 300)
        .clipped()
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var heroBackground: some View {
        Group {
            if menu.heroImageURL != nil {
                Color.clear
                    .overlay {
                        RemoteImageView(url: menu.heroImageURL)
                    }
                    .clipped()
            } else {
                Color.klikHero
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    @ViewBuilder
    private var heroOverlay: some View {
        if menu.heroImageURL != nil {
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

    private var heroContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            topBar

            Text(menu.name)
                .font(.system(.largeTitle, design: .serif).weight(.bold))
                .foregroundStyle(Color.klikHeroText)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let description = menu.description {
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
        .padding(.top, (topSafeAreaInset > 0 ? topSafeAreaInset : 59) + 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 52)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("KLIKMENU")
                .font(.caption.weight(.bold))
                .tracking(2.2)
                .foregroundStyle(Color.klikAccent)
                .accessibilityAddTraits(.isHeader)
                .lineLimit(1)
                .layoutPriority(1)

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
                    .background(
                        Circle()
                            .fill(Color.klikSurface.opacity(0.92))
                    )
            }
            .layoutPriority(2)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FeedbackActionButton: View {
    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color(red: 183 / 255, green: 121 / 255, blue: 0))
                    .accessibilityHidden(true)

                if !compact {
                    Text("Oceń obsługę")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.klikText)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, compact ? 0 : 14)
            .frame(width: compact ? 44 : nil, height: 44)
            .background(Color.klikSurface, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.klikBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Oceń obsługę")
        .accessibilityHint("Otwiera formularz oceny obsługi")
    }
}
