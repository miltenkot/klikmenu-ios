import SwiftUI

struct MenuFeedRowView: View {
    let row: MenuFeedRow

    var body: some View {
        Group {
            switch row {
            case let .categoryHeader(_, name, description, isFirstCategory, edge):
                MenuCategoryHeaderRow(name: name, description: description)
                    .menuCategoryCardChrome(edge: edge)
                    .padding(.top, isFirstCategory ? -12 : 18)
            case let .subcategoryHeader(_, name, description, edge):
                MenuSubcategoryHeaderRow(name: name, description: description)
                    .menuCategoryCardChrome(edge: edge)
            case let .item(item, currency, showsDividerAbove, edge):
                VStack(spacing: 0) {
                    if showsDividerAbove {
                        Divider().overlay { Color.klikBorder.opacity(0.85) }
                    }
                    MenuItemCardView(item: item, currency: currency)
                }
                .menuCategoryCardChrome(edge: edge)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct MenuCategoryHeaderRow: View {
    let name: String
    let description: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.system(.title, design: .serif).weight(.bold))
                .foregroundStyle(Color.klikText)
            if let description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color.klikMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 12)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct MenuSubcategoryHeaderRow: View {
    let name: String
    let description: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .overlay { Color.klikBorder }
                .padding(.top, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(Color.klikText)
                if let description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(Color.klikMuted)
                }
            }
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

private extension View {
    func menuCategoryCardChrome(edge: MenuCardEdge) -> some View {
        modifier(MenuCategoryCardChrome(edge: edge))
    }
}

private struct MenuCategoryCardChrome: ViewModifier {
    let edge: MenuCardEdge

    private let cornerRadius: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 18)
            .padding(.top, padsTop ? 18 : 0)
            .padding(.bottom, padsBottom ? 18 : 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { backgroundShape.fill(Color.klikSurface) }
            .overlay { edgeStroke }
            .shadow(
                color: showsShadow ? Color.black.opacity(0.04) : .clear,
                radius: showsShadow ? 8 : 0,
                y: showsShadow ? 3 : 0
            )
    }

    private var padsTop: Bool {
        edge == .top || edge == .single
    }

    private var padsBottom: Bool {
        edge == .bottom || edge == .single
    }

    private var showsShadow: Bool {
        edge == .bottom || edge == .single
    }

    @ViewBuilder
    private var edgeStroke: some View {
        switch edge {
        case .middle:
            HStack(spacing: 0) {
                Color.klikBorder.frame(width: 1)
                Spacer(minLength: 0)
                Color.klikBorder.frame(width: 1)
            }
            .allowsHitTesting(false)
        case .top, .bottom, .single:
            backgroundShape.stroke(Color.klikBorder, lineWidth: 1)
        }
    }

    private var backgroundShape: UnevenRoundedRectangle {
        switch edge {
        case .top:
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: cornerRadius,
                style: .continuous
            )
        case .middle:
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0,
                style: .continuous
            )
        case .bottom:
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: cornerRadius,
                topTrailingRadius: 0,
                style: .continuous
            )
        case .single:
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius,
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: cornerRadius,
                topTrailingRadius: cornerRadius,
                style: .continuous
            )
        }
    }
}
