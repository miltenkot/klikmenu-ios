import KlikMenuCore
import SwiftUI

struct ContentView: View {
    @State private var route: RestaurantMenuRoute?
    @State private var lastRejectedCode: String?
    @State private var scannerResetID = UUID()
    @State private var isOrderBarVisible = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RestaurantMenuSessionView(
                route: $route,
                handlesSystemInvocation: true,
                onOrderBarVisibilityChanged: { isVisible in
                    isOrderBarVisible = isVisible
                }
            ) {
                QRScannerScreen(
                    route: $route,
                    scannerResetID: $scannerResetID,
                    lastRejectedCode: $lastRejectedCode
                )
            }

            if route != nil {
                Button("Skanuj ponownie", systemImage: "qrcode.viewfinder", action: rescan)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(.ultraThinMaterial, in: Capsule())
                    .buttonStyle(.plain)
                    .padding(.leading, 16)
                    .safeAreaPadding(.bottom, isOrderBarVisible ? 86 : 16)
                    .accessibilityHint(Text("Wróć do skanera kodów QR"))
            }
        }
        .onChange(of: route) { _, newRoute in
            if newRoute == nil {
                isOrderBarVisible = false
            }
        }
    }

    private func rescan() {
        route = nil
        lastRejectedCode = nil
        scannerResetID = UUID()
    }
}
