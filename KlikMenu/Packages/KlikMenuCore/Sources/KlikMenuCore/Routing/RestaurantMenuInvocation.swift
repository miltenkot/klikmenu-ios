import Foundation

/// Resolves KlikMenu invocation payloads (App Clip URL, QR code, debug slug).
public enum RestaurantMenuInvocation {
    public static let invalidLinkMessage =
        "Link musi mieć postać https://app.klikmenu.pl/menu/{slug}."

    public static func route(from raw: String) -> RestaurantMenuRoute? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let parsed = RestaurantMenuURLParser.parse(trimmed) {
            return parsed
        }
        guard !trimmed.isEmpty, !trimmed.contains("://") else { return nil }
        return RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/\(trimmed)")
    }

    public static func route(from url: URL) -> RestaurantMenuRoute? {
        RestaurantMenuURLParser.parse(url)
    }
}
