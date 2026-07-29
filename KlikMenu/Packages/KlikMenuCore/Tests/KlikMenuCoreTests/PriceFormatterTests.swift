import Foundation
import Testing
@testable import KlikMenuCore

@Test func formatsPolishCurrency() {
    let formatted = PriceFormatter.string(price: "24.00", currency: "PLN")
    #expect(formatted.contains("24,00"))
    #expect(
        formatted.localizedCaseInsensitiveContains("zł")
            || formatted.localizedCaseInsensitiveContains("pln")
    )
}
