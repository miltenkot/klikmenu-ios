import SwiftUI

struct MenuSearchFloatingButton: View {
    let action: () -> Void
    var size: CGFloat = 60

    var body: some View {
        Button(action: action) {
            Label {
                Text("Przeglądaj i wyszukaj menu", bundle: #bundle)
            } icon: {
                Image(systemName: "magnifyingglass")
            }
            .labelStyle(.iconOnly)
            .font(.title3.weight(.semibold))
            .foregroundStyle(Color.klikAccent)
            .frame(width: size, height: size)
            .modifier(MenuCircleButtonBackground())
            .padding(6)
            // Include the transparent margin in the button's touch target.
            .contentShape(.interaction, Rectangle())
        }
            .buttonStyle(.plain)
            .accessibilityIdentifier("menuSearchFloatingButton")
            .accessibilityInputLabels([
                String(localized: "Szukaj w menu", bundle: #bundle),
                String(localized: "Przeglądaj i wyszukaj menu", bundle: #bundle)
            ])
            .accessibilityHint(Text("Otwiera natywne wyszukiwanie i filtry", bundle: #bundle))
            .accessibilityRespondsToUserInteraction(true)
    }
}
