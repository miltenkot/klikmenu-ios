import SwiftUI

public struct OrderListSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(OrderListStore.self) private var orderListStore

    public init() {}

    public var body: some View {
        NavigationStack {
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
            .navigationTitle(Text("Twoje zamówienie", bundle: #bundle))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !orderListStore.items.isEmpty {
                        Button(LocalizedStringResource("Wyczyść", bundle: #bundle)) {
                            orderListStore.clear()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringResource("Gotowe", bundle: #bundle), action: dismiss.callAsFunction)
                        .frame(minHeight: 44)
                }
            }
        }
        .presentationDetents([.large])
    }
}
