import KlikMenuCore
import SwiftUI

struct ContentView: View {
    @State private var route: RestaurantMenuRoute?
    @State private var lastRejectedCode: String?
    @State private var scannerResetID = UUID()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RestaurantMenuSessionView(
                route: $route,
                handlesSystemInvocation: true
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
                    .safeAreaPadding(.bottom, 16)
                    .accessibilityHint(Text("Wróć do skanera kodów QR"))
            }
        }
    }

    private func rescan() {
        route = nil
        lastRejectedCode = nil
        scannerResetID = UUID()
    }
}
