import SwiftUI

struct AddToOrderControlView: View {
    @Environment(OrderListStore.self) private var orderListStore

    let item: MenuItem
    let variant: MenuItemVariant?

    private var lineKey: String {
        OrderListItem.lineKey(menuItemID: item.id, variantID: variant?.id)
    }

    var body: some View {
        if orderListStore.showsOrderUI {
            if let quantity = orderListStore.quantity(for: lineKey), quantity > 0 {
                OrderQuantityStepperView(
                    quantity: quantity,
                    accessibilityName: accessibilityName,
                    onDecrease: { orderListStore.decrement(lineKey: lineKey) },
                    onIncrease: { orderListStore.increment(lineKey: lineKey) }
                )
            } else {
                Button {
                    orderListStore.add(item: item, variant: variant)
                } label: {
                    Text("Dodaj", bundle: #bundle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.klikHeroText)
                        .padding(.horizontal, 16)
                        .frame(minWidth: 72, minHeight: 44)
                        .background(Color.klikAccent, in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(Color.klikHeroText, lineWidth: 2)
                                .allowsHitTesting(false)
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Dodaj \(accessibilityName)", bundle: #bundle))
                .accessibilityInputLabels([
                    Text("Dodaj \(accessibilityName)", bundle: #bundle),
                    Text(accessibilityName)
                ])
            }
        }
    }

    private var accessibilityName: String {
        if let variant {
            if let detail = variant.detail, !detail.isEmpty {
                return "\(item.name), \(variant.label), \(detail)"
            }
            return "\(item.name), \(variant.label)"
        }
        return item.name
    }
}

struct OrderQuantityStepperView: View {
    let quantity: Int
    let accessibilityName: String
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onDecrease) {
                Image(systemName: "minus")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.klikAccent)
                    .frame(width: 44, height: 44)
                    .background(Color.klikAccent.opacity(0.16), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Zmniejsz ilość \(accessibilityName)", bundle: #bundle))

            Text("\(quantity)")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(minWidth: 20)

            Button(action: onIncrease) {
                Image(systemName: "plus")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.klikHeroText)
                    .frame(width: 44, height: 44)
                    .background(Color.klikAccent, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Zwiększ ilość \(accessibilityName)", bundle: #bundle))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Ilość \(accessibilityName)", bundle: #bundle))
        .accessibilityValue(Text("\(quantity)", bundle: #bundle))
        .accessibilityHint(Text("Przesuń w górę lub w dół, aby zmienić ilość.", bundle: #bundle))
        .accessibilityInputLabels([
            Text("Ilość \(accessibilityName)", bundle: #bundle),
            Text("Zmień ilość \(accessibilityName)", bundle: #bundle),
            Text(accessibilityName)
        ])
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                onIncrease()
            case .decrement:
                onDecrease()
            @unknown default:
                break
            }
        }
    }
}
