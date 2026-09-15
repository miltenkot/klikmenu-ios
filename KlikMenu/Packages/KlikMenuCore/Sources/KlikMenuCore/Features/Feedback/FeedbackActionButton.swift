import SwiftUI

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
                    Text("Oceń obsługę", bundle: #bundle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.klikText)
                }
            }
            .padding(.horizontal, compact ? 0 : 14)
            .padding(.vertical, compact ? 0 : 10)
            .frame(width: compact ? 44 : nil)
            .frame(minHeight: 44)
            .background(Color.klikSurface, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.klikBorder, lineWidth: 1)
            }
            .contentShape(.capsule)
            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)
        }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Oceń obsługę", bundle: #bundle))
            .accessibilityHint(Text("Otwiera formularz oceny obsługi", bundle: #bundle))
    }
}
