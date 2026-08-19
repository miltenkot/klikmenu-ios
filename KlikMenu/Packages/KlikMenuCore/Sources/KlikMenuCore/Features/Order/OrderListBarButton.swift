import SwiftUI

struct OrderListBarButton: View {
    let quantity: Int
    let totalText: String
    let action: () -> Void
    var height: CGFloat = 56

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Twoje zamówienie", bundle: #bundle)
                    .font(.subheadline.weight(.semibold))
                Text("·")
                    .foregroundStyle(Color.klikMuted)
                Text("\(quantity)")
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                Text("·")
                    .foregroundStyle(Color.klikMuted)
                Text(totalText)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
            }
            .foregroundStyle(Color.klikHeroText)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.klikAccent, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.klikHeroText, lineWidth: 2)
            }
        }
        .buttonStyle(OrderListStaticPressButtonStyle())
        .shadow(color: Color.black.opacity(0.18), radius: 10, y: 4)
        .accessibilityLabel(Text("Twoje zamówienie, \(quantity), \(totalText)", bundle: #bundle))
    }
}

private struct OrderListStaticPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
