import SwiftUI

public struct MenuLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("KLIKMENU", bundle: #bundle)
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(Color.klikHeroMuted)

                HStack(alignment: .top, spacing: 12) {
                    if !reduceMotion {
                        ProgressView()
                            .tint(Color.klikAccent)
                            .accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ładujemy menu…", bundle: #bundle)
                            .font(.system(.largeTitle, design: .serif).weight(.bold))
                            .foregroundStyle(Color.klikHeroText)
                        Text("Przygotowujemy kartę dań restauracji.", bundle: #bundle)
                            .foregroundStyle(Color.klikHeroMuted)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { Color.klikHero }

            Spacer(minLength: 16)

            skeletonCard

            Spacer(minLength: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.klikPageBackground.ignoresSafeArea() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Ładujemy menu…", bundle: #bundle))
    }

    private var skeletonCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.klikBorder.opacity(0.7))
                .frame(width: 140, height: 18)
            ForEach(0..<3, id: \.self) { _ in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.klikBorder.opacity(0.7))
                            .frame(height: 14)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.klikBorder.opacity(0.45))
                            .frame(height: 10)
                    }
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.klikBorder.opacity(0.7))
                        .frame(width: 48, height: 14)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { Color.klikSurface }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
    }
}
