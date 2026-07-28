import Foundation

/// API menu locale values from OpenAPI `GET /api/v1/public/restaurants/{slug}/menu`.
public enum SupportedLocale: String, CaseIterable, Codable, Sendable, Hashable {
    case pl
    case en
    case de
    case uk
    case cs
    case sk

    public static let `default`: SupportedLocale = .pl
}

public struct AppLanguageResolver: Sendable {
    private let preferredLocalizationsProvider: @Sendable () -> [String]

    public init(preferredLocalizations: [String]) {
        self.preferredLocalizationsProvider = { preferredLocalizations }
    }

    public init(bundle: Bundle = .main) {
        self.preferredLocalizationsProvider = { bundle.preferredLocalizations }
    }

    /// Test/helper initializer for values that can change between calls.
    public init(preferredLocalizationsProvider: @escaping @Sendable () -> [String]) {
        self.preferredLocalizationsProvider = preferredLocalizationsProvider
    }

    /// Resolves the app-language preference (Settings → Apps → Language) to an API locale.
    public func resolve() -> SupportedLocale {
        Self.resolve(from: preferredLocalizationsProvider())
    }

    public static func resolve(from preferredLocalizations: [String]) -> SupportedLocale {
        for localization in preferredLocalizations {
            if let locale = map(localization) {
                return locale
            }
        }
        return .default
    }

    public static func resolve(languageCode: String) -> SupportedLocale {
        map(languageCode) ?? .default
    }

    private static func map(_ localization: String) -> SupportedLocale? {
        let normalized = localization
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()
        guard !normalized.isEmpty else { return nil }

        let language = normalized.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? normalized

        return SupportedLocale(rawValue: language)
    }
}
