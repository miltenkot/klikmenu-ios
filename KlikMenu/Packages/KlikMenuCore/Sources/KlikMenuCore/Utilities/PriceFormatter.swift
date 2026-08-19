import Foundation

public enum PriceFormatter {
    /// Menu prices are shown with Polish number formatting (comma decimals),
    /// independent of the device/UI language used for app chrome.
    private static let displayLocale = Locale(identifier: "pl_PL")

    public static func string(price: String, currency: String) -> String {
        guard let value = Decimal(string: price, locale: Locale(identifier: "en_US_POSIX")) else {
            return "\(price) \(currency)"
        }
        return string(decimal: value, currency: currency)
    }

    public static func string(decimal: Decimal, currency: String) -> String {
        decimal.formatted(
            .currency(code: currency)
                .locale(displayLocale)
        )
    }
}
