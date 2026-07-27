import SwiftUI

public enum ThemePreference: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    public static let storageKey = "klikmenu-theme"

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    public var label: LocalizedStringResource {
        switch self {
        case .system: LocalizedStringResource("Systemowy", bundle: #bundle)
        case .light: LocalizedStringResource("Jasny", bundle: #bundle)
        case .dark: LocalizedStringResource("Ciemny", bundle: #bundle)
        }
    }

    var iconName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}

public struct PreferredColorSchemeModifier: ViewModifier {
    @AppStorage(ThemePreference.storageKey) private var stored = ThemePreference.system.rawValue

    public init() {}

    public func body(content: Content) -> some View {
        content.preferredColorScheme(
            (ThemePreference(rawValue: stored) ?? .system).colorScheme
        )
    }
}

extension View {
    public func klikMenuPreferredColorScheme() -> some View {
        modifier(PreferredColorSchemeModifier())
    }
}
