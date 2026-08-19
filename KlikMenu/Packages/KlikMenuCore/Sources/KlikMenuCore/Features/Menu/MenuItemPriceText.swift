import SwiftUI

struct MenuItemPriceText: View {
    let price: String
    let currency: String

    var body: some View {
        if let value = Decimal(string: price, locale: Locale(identifier: "en_US_POSIX")) {
            Text(value, format: .currency(code: currency))
        } else {
            Text(verbatim: "\(price) \(currency)")
        }
    }
}
