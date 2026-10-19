import SwiftUI

struct MenuSearchFloatingButton: View {
    let action: () -> Void
    var size: CGFloat = 60

    var body: some View {
        Button(
            LocalizedStringResource("Przeglądaj i wyszukaj menu", bundle: #bundle),
            systemImage: "magnifyingglass",
            action: action
        )
            .labelStyle(.iconOnly)
            .font(.title3.weight(.semibold))
            .foregroundStyle(Color.klikAccent)
            .frame(width: size, height: size)
            .buttonStyle(.plain)
            .modifier(MenuCircleButtonBackground())
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityInputLabels([
                String(localized: "Szukaj w menu", bundle: #bundle),
                String(localized: "Przeglądaj i wyszukaj menu", bundle: #bundle)
            ])
            .accessibilityHint(Text("Otwiera natywne wyszukiwanie i filtry", bundle: #bundle))
            .accessibilityRespondsToUserInteraction(true)
    }
}
