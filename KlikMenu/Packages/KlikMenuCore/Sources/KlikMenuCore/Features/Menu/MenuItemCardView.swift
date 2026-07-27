import SwiftUI

public struct MenuItemCardView: View {
    public let item: MenuItem
    public let currency: String

    public init(item: MenuItem, currency: String) {
        self.item = item
        self.currency = currency
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if item.imageURL != nil {
                RemoteImageView(url: item.imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundStyle(Color.klikText)
                            .fixedSize(horizontal: false, vertical: true)

                        if let dietaryLabel = item.dietaryType.displayLabel {
                            Text(dietaryLabel)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.klikDietaryBackground, in: Capsule())
                                .overlay {
                                    Capsule().stroke(Color.klikDietaryBorder, lineWidth: 1)
                                }
                                .foregroundStyle(Color.klikDietaryText)
                                .accessibilityLabel(Text(dietaryLabel))
                        }
                    }

                    Spacer(minLength: 8)

                    priceText
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.klikAccent)
                }

                if let servingSize = item.servingSize {
                    Text(servingSize)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.klikMuted)
                }

                if let description = item.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color.klikMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let ingredients = item.ingredients {
                    Text("Składniki: \(ingredients)", bundle: #bundle)
                        .font(.footnote)
                        .foregroundStyle(Color.klikMuted)
                }

                if !item.allergens.isEmpty {
                    Text("Alergeny: \(item.allergens.formatted())", bundle: #bundle)
                        .font(.footnote)
                        .foregroundStyle(Color.klikMuted)
                }
            }
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var priceText: some View {
        if let value = Decimal(string: item.price, locale: Locale(identifier: "en_US_POSIX")) {
            Text(value, format: .currency(code: currency).locale(Locale(identifier: "pl_PL")))
        } else {
            Text(verbatim: "\(item.price) \(currency)")
        }
    }
}
