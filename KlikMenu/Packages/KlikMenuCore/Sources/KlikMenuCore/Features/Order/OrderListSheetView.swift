import SwiftUI

public struct OrderListSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(OrderListStore.self) private var orderListStore

    public init() {}

    public var body: some View {
        NavigationStack {
            OrderListContentView()
            .navigationTitle(Text("Twoje zamówienie", bundle: #bundle))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !orderListStore.items.isEmpty {
                        Button(LocalizedStringResource("Wyczyść", bundle: #bundle)) {
                            orderListStore.clear()
                        }
                        .tint(Color.klikAccent)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringResource("Gotowe", bundle: #bundle), action: dismiss.callAsFunction)
                        .frame(minHeight: 44)
                        .tint(Color.klikAccent)
                }
            }
        }
        .presentationDetents([.large])
    }
}


