import Foundation

public enum PriceFormatter {
    public static func string(price: String, currency: String) -> String {
        guard let value = Decimal(string: price, locale: Locale(identifier: "en_US_POSIX")) else {
            return "\(price) \(currency)"
        }
        return value.formatted(
            .currency(code: currency)
                .locale(Locale(identifier: "pl_PL"))
        )
    }
}
