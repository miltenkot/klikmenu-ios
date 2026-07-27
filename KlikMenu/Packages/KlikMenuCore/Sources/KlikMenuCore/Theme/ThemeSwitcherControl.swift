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
            }
        }
        .labelStyle(.iconOnly)
        .font(.body.weight(.semibold))
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .accessibilityValue(Text(preference.label))
        .accessibilityHint(Text("Wybierz motyw jasny, ciemny lub systemowy", bundle: #bundle))
    }
}
