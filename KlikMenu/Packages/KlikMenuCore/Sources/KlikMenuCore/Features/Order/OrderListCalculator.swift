import Foundation

enum OrderListCalculator {
    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    static func decimal(from price: String) -> Decimal? {
        Decimal(string: price, locale: posixLocale)
    }

    static func productsSubtotal(items: [OrderListItem]) -> Decimal {
        items.reduce(into: Decimal.zero) { partialResult, item in
            partialResult += item.lineSubtotal
        }
    }

    static func serviceChargeAmount(
        productsSubtotal: Decimal,
        serviceCharge: ServiceCharge?
    ) -> Decimal {
        guard let serviceCharge else { return 0 }

        switch serviceCharge.type {
        case .fixed:
            return roundMoney(serviceCharge.value)
        case .percentage:
            let amount = productsSubtotal * serviceCharge.value / 100
            return roundMoney(amount)
        }
    }

    static func total(
        productsSubtotal: Decimal,
        serviceCharge: ServiceCharge?
    ) -> Decimal {
        roundMoney(productsSubtotal + serviceChargeAmount(
            productsSubtotal: productsSubtotal,
            serviceCharge: serviceCharge
        ))
    }

    static func roundMoney(_ value: Decimal) -> Decimal {
        var input = value
        var output = Decimal.zero
        NSDecimalRound(&output, &input, 2, .plain)
        return output
    }

    static func percentageSuffix(for serviceCharge: ServiceCharge) -> String? {
        guard serviceCharge.type == .percentage else { return nil }
        let normalized = serviceCharge.value.formatted(
            .number
                .locale(posixLocale)
                .precision(.fractionLength(0...2))
        )
        return "\(normalized)%"
    }
}
