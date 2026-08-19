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
            Text("Alergeny: \(item.allergens.formatted())", bundle: #bundle)
                .font(.footnote)
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
