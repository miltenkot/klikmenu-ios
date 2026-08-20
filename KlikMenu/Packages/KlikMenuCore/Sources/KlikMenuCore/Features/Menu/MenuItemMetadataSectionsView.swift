import SwiftUI

struct MenuItemMetadataSectionsView: View {
    let item: MenuItem
    var usesSecondaryForeground = false

    private var textColor: Color {
        usesSecondaryForeground ? Color.secondary : Color.klikMuted
    }

    var body: some View {
        if let description = item.description {
            Text(description)
                .font(.subheadline)
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }

        if let ingredients = item.ingredients {
            Text("Składniki: \(ingredients)", bundle: #bundle)
                .font(.footnote)
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }

        if !item.allergens.isEmpty {
            Label {
                Text("Alergeny: \(allergensText)", bundle: #bundle)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .accessibilityHidden(true)
            }
            .font(.footnote)
            .foregroundStyle(Color.klikAccent)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Uwaga, alergeny: \(allergensText)", bundle: #bundle))
        }
    }

    private var allergensText: String {
        item.allergens.formatted()
    }
}
