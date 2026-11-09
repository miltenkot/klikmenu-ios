import SwiftUI

public struct MenuItemCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    public let item: MenuItem
    public let currency: String

    public init(item: MenuItem, currency: String) {
        self.item = item
        self.currency = currency
    }

    public var body: some View {
        MenuItemCardContentLayout(allowsHorizontalLayout: !dynamicTypeSize.isAccessibilitySize) {
            if item.imageURL != nil {
                RemoteImageView(url: item.imageURL, cacheKey: item.imageKey)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                MenuItemCardHeaderView(item: item, currency: currency)

                if !item.variants.isEmpty {
                    MenuItemVariantsListView(item: item, variants: item.variants, currency: currency)
                }

                if item.variants.isEmpty, let servingSize = item.servingSize {
                    Text(servingSize)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.klikMuted)
                }

                MenuItemCardMetadataSectionsView(item: item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .accessibilityElement(children: .contain)
        .modifier(MenuItemDetailPresentation(item: item, currency: currency, isCardContainer: true))
    }
}

/// Uses the card's available width, including when the menu occupies only one pane.
private struct MenuItemCardContentLayout: Layout {
    let allowsHorizontalLayout: Bool

    private func isHorizontal(width: CGFloat) -> Bool {
        allowsHorizontalLayout && width >= 420
    }

    private func imageSize(width: CGFloat) -> CGSize {
        let imageWidth = isHorizontal(width: width) ? min(220, width * 0.36) : min(width, 360)
        return CGSize(width: imageWidth, height: imageWidth * 0.75)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = max(0, proposal.width ?? 360)
        guard subviews.count == 2 else {
            let height = subviews.first?.sizeThatFits(ProposedViewSize(width: width, height: nil)).height ?? 0
            return CGSize(width: width, height: height)
        }

        let image = imageSize(width: width)
        let horizontal = isHorizontal(width: width)
        let detailsWidth = horizontal ? width - image.width - 20 : width
        let details = subviews[1].sizeThatFits(ProposedViewSize(width: detailsWidth, height: nil))
        return CGSize(
            width: width,
            height: horizontal ? max(image.height, details.height) : image.height + 12 + details.height
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 2 else {
            subviews.first?.place(
                at: bounds.origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: bounds.width, height: nil)
            )
            return
        }

        let image = imageSize(width: bounds.width)
        let horizontal = isHorizontal(width: bounds.width)
        subviews[0].place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(image)
        )
        subviews[1].place(
            at: CGPoint(
                x: bounds.minX + (horizontal ? image.width + 20 : 0),
                y: bounds.minY + (horizontal ? 0 : image.height + 12)
            ),
            anchor: .topLeading,
            proposal: ProposedViewSize(
                width: horizontal ? bounds.width - image.width - 20 : bounds.width,
                height: nil
            )
        )
    }
}

private enum MenuItemCardLayout {
    static let postVariantsSpacing: CGFloat = 14
}

private struct MenuItemCardHeaderView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let item: MenuItem
    let currency: String

    private var itemTitle: some View {
        Text(item.name)
            .font(.headline)
            .foregroundStyle(Color.klikText)
            .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))

        layout {
            VStack(alignment: .leading, spacing: 6) {
                itemTitle
                    .modifier(MenuItemDetailPresentation(item: item, currency: currency))

                MenuItemBadgesView(dietaryType: item.dietaryType, spicinessLevel: item.spicinessLevel)
            }

            if item.variants.isEmpty {
                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer(minLength: 8)
                }

                VStack(alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .trailing, spacing: 8) {
                    MenuItemPriceText(price: item.price, currency: currency)
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.klikAccent)

                    AddToOrderControlView(item: item, variant: nil)
                }
            }
        }
    }
}

private struct MenuItemCardMetadataSectionsView: View {
    let item: MenuItem

    var body: some View {
        let hasVariants = !item.variants.isEmpty

        if let description = item.description {
            Text(description)
                .font(.subheadline)
                .foregroundStyle(Color.klikMuted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, hasVariants ? MenuItemCardLayout.postVariantsSpacing - 8 : 0)
        }

        if let ingredients = item.ingredients {
            Text("Składniki: \(ingredients)", bundle: #bundle)
                .font(.footnote)
                .foregroundStyle(Color.klikMuted)
                .padding(.top, hasVariants && item.description == nil ? MenuItemCardLayout.postVariantsSpacing - 8 : 0)
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
            .padding(.top, hasVariants && item.description == nil && item.ingredients == nil
                ? MenuItemCardLayout.postVariantsSpacing - 8
                : 0)
        }
    }

    private var allergensText: String {
        item.allergens.formatted()
    }
}
