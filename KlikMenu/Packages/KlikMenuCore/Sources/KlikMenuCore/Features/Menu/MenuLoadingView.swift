import SwiftUI

public struct MenuLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false
    public var topSafeAreaInset: CGFloat

    public init(topSafeAreaInset: CGFloat? = nil) {
        self.topSafeAreaInset = topSafeAreaInset ?? LayoutMetrics.fallbackTopSafeAreaInset
    }

    public var body: some View {
        VStack(spacing: 0) {
            MenuLoadingHeroView(
                topSafeAreaInset: topSafeAreaInset,
                showsProgress: !reduceMotion
            )
            MenuLoadingSkeletonCard(isPulsing: reduceMotion ? true : pulse)
                .padding(.horizontal, 16)
                .offset(y: -28)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { Color.klikPageBackground.ignoresSafeArea() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Ładujemy menu…", bundle: #bundle))
        .task(id: reduceMotion) {
            guard !reduceMotion else {
                pulse = false
                return
            }
            withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
