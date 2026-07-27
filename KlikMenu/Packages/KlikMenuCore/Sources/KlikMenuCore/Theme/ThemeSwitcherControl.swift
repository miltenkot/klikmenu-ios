import SwiftUI

public struct ThemeSwitcherControl: View {
    @AppStorage(ThemePreference.storageKey) private var stored = ThemePreference.system.rawValue

    public init() {}

    private var preference: ThemePreference {
        ThemePreference(rawValue: stored) ?? .system
    }

    public var body: some View {
        Menu {
            Picker("Motyw", selection: $stored) {
                ForEach(ThemePreference.allCases, id: \.rawValue) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
        } label: {
            Image(systemName: preference.iconName)
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Motyw aplikacji")
        .accessibilityValue(preference.label)
        .accessibilityHint("Wybierz motyw jasny, ciemny lub systemowy")
    }
}

extension ThemePreference {
    public static let storageKey = "klikmenu-theme"

    public var label: String {
        switch self {
        case .system: "Systemowy"
        case .light: "Jasny"
        case .dark: "Ciemny"
        }
    }

    fileprivate var iconName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}
