import SwiftUI

struct MenuItemBadgesView: View {
    let dietaryType: DietaryType
    let spicinessLevel: SpicinessLevel

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                DietaryBadgeView(dietaryType: dietaryType)
                SpicinessBadgeView(spicinessLevel: spicinessLevel)
            }

            VStack(alignment: .leading, spacing: 6) {
                DietaryBadgeView(dietaryType: dietaryType)
                SpicinessBadgeView(spicinessLevel: spicinessLevel)
            }
        }
    }
}

private struct DietaryBadgeView: View {
    let dietaryType: DietaryType

    var body: some View {
        if let dietaryLabel = dietaryType.displayLabel {
            Label {
                Text(dietaryLabel)
            } icon: {
                Image(systemName: dietaryType.symbolName)
                    .accessibilityHidden(true)
            }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.klikDietaryBackground, in: Capsule())
                .overlay {
                    Capsule().stroke(Color.klikDietaryBorder, lineWidth: 1)
                }
                .foregroundStyle(Color.klikDietaryText)
                .labelStyle(.titleAndIcon)
                .accessibilityLabel(Text(dietaryLabel))
        }
    }
}

struct SpicinessBadgeView: View {
    let spicinessLevel: SpicinessLevel

    var body: some View {
        if let label = spicinessLevel.displayLabel {
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<spicinessLevel.chiliCount, id: \.self) { _ in
                        ChiliIconView()
                            .accessibilityHidden(true)
                    }
                }
                Text(label)
            }
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.klikSpicyBackground, in: Capsule())
            .overlay {
                Capsule().stroke(Color.klikSpicyBorder, lineWidth: 1)
            }
            .foregroundStyle(Color.klikSpicyText)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(spicinessLevel.accessibilityLabel ?? label))
        }
    }
}

struct ChiliIconView: View {
    var body: some View {
        Image(systemName: "flame.fill")
            .font(.caption2.weight(.bold))
    }
}

private extension DietaryType {
    var symbolName: String {
        switch self {
        case .none:
            "circle"
        case .vegetarian:
            "leaf"
        case .vegan:
            "leaf.fill"
        }
    }
}
