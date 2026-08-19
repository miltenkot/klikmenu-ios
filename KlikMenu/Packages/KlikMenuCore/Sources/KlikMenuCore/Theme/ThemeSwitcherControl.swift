import SwiftUI

public struct ThemeSwitcherControl: View {
    @AppStorage(ThemePreference.storageKey) private var stored = ThemePreference.system.rawValue

    public init() {}

    private var preference: ThemePreference {
        ThemePreference(rawValue: stored) ?? .system
    }

    public var body: some View {
        Menu {
            Picker(selection: $stored) {
                ForEach(ThemePreference.allCases, id: \.rawValue) { option in
                    Text(option.label).tag(option.rawValue)
                }
            } label: {
                Text("Motyw", bundle: #bundle)
            }
        } label: {
            Label {
                Text("Motyw aplikacji", bundle: #bundle)
            } icon: {
                Image(systemName: preference.iconName)
                    .frame(width: 44, height: 44)
            }
        }
        .labelStyle(.iconOnly)
        .font(.body.weight(.semibold))
        .frame(width: 52, height: 52)
        .contentShape(.circle)
        .accessibilityValue(Text(preference.label))
        .accessibilityHint(Text("Wybierz motyw jasny, ciemny lub systemowy", bundle: #bundle))
    }
}
