import SwiftUI

public struct ThemeSwitcherControl: View {
    @AppStorage(ThemePreference.storageKey) private var stored = ThemePreference.system.rawValue

    public init() {}

    private var preference: ThemePreference {
        ThemePreference(rawValue: stored) ?? .system
    }

    public var body: some View {
        Menu("Motyw aplikacji", systemImage: preference.iconName) {
            Picker("Motyw", selection: $stored) {
                ForEach(ThemePreference.allCases, id: \.rawValue) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
        }
        .labelStyle(.iconOnly)
        .font(.body.weight(.semibold))
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .accessibilityValue(preference.label)
        .accessibilityHint("Wybierz motyw jasny, ciemny lub systemowy")
    }
}
