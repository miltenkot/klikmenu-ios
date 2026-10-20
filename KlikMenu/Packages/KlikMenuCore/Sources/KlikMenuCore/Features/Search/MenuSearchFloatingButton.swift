import SwiftUI

struct MenuSearchFloatingButton: View {
    let action: () -> Void
    var size: CGFloat = 60
    @ScaledMetric(relativeTo: .title3) private var sizeScale: CGFloat = 1

    private var buttonSize: CGFloat { max(44, size * sizeScale) }

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
            .frame(width: buttonSize, height: buttonSize)
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
