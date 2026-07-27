import Foundation

public enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pl_PL")
        return formatter
    }()

    public static func string(price: String, currency: String) -> String {
        guard let value = Decimal(string: price, locale: Locale(identifier: "en_US_POSIX")) else {
            return "\(price) \(currency)"
        }
        formatter.currencyCode = currency
        return formatter.string(from: value as NSDecimalNumber) ?? "\(price) \(currency)"
    }
}
