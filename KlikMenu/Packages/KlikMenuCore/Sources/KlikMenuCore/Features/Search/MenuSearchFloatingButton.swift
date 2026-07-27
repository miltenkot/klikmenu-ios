import SwiftUI

struct MenuSearchFloatingButton: View {
    let action: () -> Void

    var body: some View {
        Button(
            LocalizedStringResource("Przeglądaj i wyszukaj menu", bundle: #bundle),
            systemImage: "magnifyingglass",
            action: action
        )
            .labelStyle(.iconOnly)
            .font(.title3.weight(.semibold))
            .foregroundStyle(Color.klikHeroText)
            .frame(width: 60, height: 60)
            .background(Color.klikAccent, in: Circle())
            .overlay {
                Circle()
                    .stroke(Color.klikHeroText, lineWidth: 2)
            }
            .shadow(color: Color.black.opacity(0.22), radius: 12, y: 6)
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityHint(Text("Otwiera natywne wyszukiwanie i filtry", bundle: #bundle))
    }
}
