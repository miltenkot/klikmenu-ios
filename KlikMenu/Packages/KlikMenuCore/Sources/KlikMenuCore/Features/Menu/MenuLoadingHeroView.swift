import SwiftUI

struct MenuLoadingHeroView: View {
    let topSafeAreaInset: CGFloat
    let showsProgress: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.klikHero

            VStack(alignment: .leading, spacing: 0) {
                Text("KLIKMENU", bundle: #bundle)
                    .font(.caption.weight(.bold))
                    .tracking(2.2)
                    .foregroundStyle(Color.klikAccent)
                    .accessibilityLabel(Text("KlikMenu", bundle: #bundle))

                Spacer(minLength: 28)

                VStack(alignment: .leading, spacing: 10) {
                    if showsProgress {
                        ProgressView()
                            .tint(Color.klikAccent)
                            .accessibilityHidden(true)
                    }

                    Text("Ładujemy menu…", bundle: #bundle)
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                        .foregroundStyle(Color.klikHeroText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Przygotowujemy kartę dań restauracji.", bundle: #bundle)
                        .font(.body)
                        .foregroundStyle(Color.klikHeroMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 48)
            }
            .padding(.horizontal, 16)
            .padding(
                .top,
                (topSafeAreaInset > 0 ? topSafeAreaInset : LayoutMetrics.fallbackTopSafeAreaInset) + 10
            )
            .padding(.bottom, 52)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 300)
    }
}
