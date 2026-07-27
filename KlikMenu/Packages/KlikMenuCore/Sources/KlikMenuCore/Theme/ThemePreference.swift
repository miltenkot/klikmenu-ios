import SwiftUI

public enum ThemePreference: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
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
