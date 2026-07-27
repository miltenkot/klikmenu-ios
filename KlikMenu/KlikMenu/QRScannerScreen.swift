import AVFoundation
import KlikMenuCore
import SwiftUI

struct QRScannerScreen: View {
    @Binding var route: RestaurantMenuRoute?
    @Binding var scannerResetID: UUID
    @Binding var lastRejectedCode: String?

    @State private var cameraAuthorized = false
    @State private var permissionDenied = false
    @State private var debugInput = "bistro-klik"

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
                    .accessibilityLabel("KlikMenu")

                Spacer()

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.9), lineWidth: 3)
                    .frame(width: 240, height: 240)
                    .accessibilityHidden(true)

                Text("Wyceluj w kod QR menu KlikMenu")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                if permissionDenied {
                    CameraPermissionPrompt(openSettings: openSettings)
                }

                #if DEBUG
                QRScannerDebugPanel(debugInput: $debugInput, open: openDebugInput)
                #endif

                Spacer(minLength: 24)
            }
            .padding()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Skaner kodów QR menu KlikMenu")
        .task {
            await requestCameraAccess()
        }
    }

    #if DEBUG
    private func openDebugInput() {
        if let parsed = RestaurantMenuInvocation.route(from: debugInput) {
            route = parsed
        }
    }
    #endif

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

#if DEBUG
private struct QRScannerDebugPanel: View {
    @Binding var debugInput: String
    let open: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug / Simulator")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.8))
            TextField("URL lub slug", text: $debugInput)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Testowy URL lub slug")
            Button("Otwórz przykładowe menu", action: open)
                .buttonStyle(.borderedProminent)
                .tint(Color.klikAccent)
                .frame(minHeight: 44)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
#endif
