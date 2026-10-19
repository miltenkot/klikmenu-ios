import SwiftUI

struct OrderListContentView: View {
    @Environment(OrderListStore.self) private var orderListStore

    var body: some View {
        Group {
            if orderListStore.items.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("Twoje zamówienie", bundle: #bundle)
                    } icon: {
                        Image(systemName: "list.bullet.clipboard")
                    }
                }
            } else {
                List {
                    Section {
                        ForEach(orderListStore.items) { item in
                            OrderListItemRowView(item: item)
                        }
                    }

                    Section {
                        OrderSummaryView(
                            currency: orderListStore.currency,
                            productsSubtotal: orderListStore.productsSubtotal,
                            serviceCharge: orderListStore.serviceCharge,
                            serviceChargeAmount: orderListStore.serviceChargeAmount,
                            total: orderListStore.total
                        )
                        .listRowBackground(Color.clear)
                    }

                    Section {
                        Text("Pokaż tę listę kelnerowi, aby łatwiej złożyć zamówienie.", bundle: #bundle)
                            .font(.footnote)
                            .foregroundStyle(Color.klikMuted)
                            .listRowBackground(Color.clear)
                    }
                }
            }
        }
    }
}
