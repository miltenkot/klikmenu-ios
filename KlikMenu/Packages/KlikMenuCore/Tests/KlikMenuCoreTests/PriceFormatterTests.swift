import Testing
@testable import KlikMenuCore
@Test func formatsPolishCurrency() { #expect(PriceFormatter.string(price: "24.00", currency: "PLN").contains("24,00")) }
