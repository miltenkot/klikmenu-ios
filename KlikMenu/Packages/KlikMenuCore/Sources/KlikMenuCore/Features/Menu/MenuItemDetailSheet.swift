import SwiftUI

struct MenuItemDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let item: MenuItem
    let currency: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if item.imageURL != nil {
                        RemoteImageView(url: item.imageURL, cacheKey: item.imageKey, contentMode: .fill)
                            .aspectRatio(4 / 3, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    Text(item.name)
                        .font(.system(.title, design: .serif).bold())
                        .foregroundStyle(Color.klikText)
                        .accessibilityAddTraits(.isHeader)

                    MenuItemBadgesView(dietaryType: item.dietaryType, spicinessLevel: item.spicinessLevel)

                    if item.variants.isEmpty {
                        MenuItemPriceText(price: item.price, currency: currency)
                            .font(.title2.bold())
                            .foregroundStyle(Color.klikAccent)
                        if let servingSize = item.servingSize {
                            Text(servingSize)
                                .foregroundStyle(Color.klikMuted)
                        }
                    }

                    MenuItemMetadataSectionsView(item: item)
                    Divider()

                    if item.variants.isEmpty {
                        AddToOrderControlView(item: item, variant: nil)
                            .disabled(!item.isAvailable)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        MenuItemVariantsListView(item: item, variants: item.variants, currency: currency)
                            .disabled(!item.isAvailable)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, item.imageURL == nil ? 64 : 12)
                .padding(.bottom, 24)
            }
            .background(Color.klikPageBackground)

            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.klikText)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Gotowe", bundle: #bundle))
            .padding(20)
        }
        .presentationDetents([.large])
        .presentationBackground(Color.klikPageBackground)
        .presentationCornerRadius(28)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
}
