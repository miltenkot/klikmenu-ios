import SwiftUI

struct FeedbackActionButton: View {
    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(LocalizedStringResource("Oceń obsługę", bundle: #bundle), systemImage: "star.fill", action: action)
            .labelStyle(FeedbackStarLabelStyle(compact: compact))
            .buttonStyle(.plain)
            .accessibilityHint(Text("Otwiera formularz oceny obsługi", bundle: #bundle))
    }
}

private struct FeedbackStarLabelStyle: LabelStyle {
    let compact: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
                .foregroundStyle(Color(red: 183 / 255, green: 121 / 255, blue: 0))
                .accessibilityHidden(true)

            if !compact {
                configuration.title
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.klikText)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, compact ? 0 : 14)
        .frame(width: compact ? 44 : nil, height: 44)
        .background(Color.klikSurface, in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color.klikBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)
    }
}
