import AVFoundation
import KlikMenuCore
import SwiftUI

struct QRScannerScreen: View {
    @Binding var route: RestaurantMenuRoute?
    @Binding var scannerResetID: UUID
    @Binding var lastRejectedCode: String?

    @State private var cameraAuthorized = false
    @State private var permissionDenied = false

    var body: some View {
        ZStack {
            if cameraAuthorized {
                QRScannerView(onCode: handleScannedCode)
                    .id(scannerResetID)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack {
                Text("KLIKMENU")
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 24)
                    .accessibilityLabel(Text("KlikMenu"))

                Spacer()

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.9), lineWidth: 3)
                    .frame(width: 240, height: 240)
                    .accessibilityHidden(true)

                Text("Wyceluj w kod QR")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                if permissionDenied {
                    CameraPermissionPrompt(openSettings: openSettings)
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Skaner kodów QR menu KlikMenu"))
        .task {
            await requestCameraAccess()
        }
    }

    private func handleScannedCode(_ code: String) {
        if code == lastRejectedCode {
            scannerResetID = UUID()
            return
        }

        if let parsed = RestaurantMenuInvocation.route(from: code) {
            route = parsed
        } else {
            lastRejectedCode = code
            scannerResetID = UUID()
        }
    }

    private func requestCameraAccess() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
            permissionDenied = false
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraAuthorized = granted
            permissionDenied = !granted
        default:
            cameraAuthorized = false
            permissionDenied = true
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private struct CameraPermissionPrompt: View {
    let openSettings: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Brak dostępu do kamery. Włącz go w Ustawieniach, aby skanować kody QR.")
                .font(.subheadline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Button("Otwórz Ustawienia", action: openSettings)
                .buttonStyle(.borderedProminent)
                .tint(Color.klikAccent)
                .frame(minHeight: 44)
        }
        .padding()
    }
}
