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
                                .overlay(
                                    Capsule().stroke(Color.klikDietaryBorder, lineWidth: 1)
                                )
                                .foregroundStyle(Color.klikDietaryText)
                                .accessibilityLabel(dietaryLabel)
                        }
                    }

                    Spacer(minLength: 8)

                    Text(PriceFormatter.string(price: item.price, currency: currency))
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
                    detailRow(title: "Składniki", value: ingredients)
                }

                if !item.allergens.isEmpty {
                    detailRow(title: "Alergeny", value: item.allergens.joined(separator: ", "))
                }
            }
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }

    private func detailRow(title: String, value: String) -> some View {
        (Text("\(title): ")
            .font(.footnote.weight(.bold))
            .foregroundStyle(Color.klikText)
         + Text(value)
            .font(.footnote)
            .foregroundStyle(Color.klikMuted))
    }
}
