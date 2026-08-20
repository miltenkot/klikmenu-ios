import AVFoundation
import KlikMenuCore
import SwiftUI
import UIKit

struct QRScannerScreen: View {
    @Binding var route: RestaurantMenuRoute?
    @Binding var scannerResetID: UUID
    @Binding var lastRejectedCode: String?

    @State private var cameraAuthorized = false
    @State private var permissionDenied = false
    @State private var isResolvingCode = false

    var body: some View {
        ZStack {
            if cameraAuthorized {
                QRScannerView(onCode: handleScannedCode)
                    .id(scannerResetID)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
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
                    .accessibilityAddTraits(.isHeader)

                if permissionDenied {
                    CameraPermissionPrompt(openSettings: openSettings)
                }

                Spacer(minLength: 24)
            }
            .padding()

            if isResolvingCode {
                QRScannerLoadingOverlay()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Skaner kodów QR menu KlikMenu"))
        .task {
            await requestCameraAccess()
        }
        .onChange(of: permissionDenied) { _, isDenied in
            if isDenied {
                announce("Brak dostępu do kamery. Otwórz Ustawienia, aby włączyć skanowanie kodów QR.")
            }
        }
    }

    private func handleScannedCode(_ code: String) {
        if code == lastRejectedCode {
            isResolvingCode = false
            scannerResetID = UUID()
            return
        }

        if let parsed = RestaurantMenuInvocation.route(from: code) {
            isResolvingCode = true
            announce("Wykryto kod QR. Wczytywanie menu.")
            DispatchQueue.main.async {
                route = parsed
            }
        } else {
            isResolvingCode = false
            lastRejectedCode = code
            scannerResetID = UUID()
            announce("Nie rozpoznano kodu QR. Spróbuj ponownie.")
        }
    }

    private func requestCameraAccess() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
            permissionDenied = false
            isResolvingCode = false
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraAuthorized = granted
            permissionDenied = !granted
            if !granted {
                isResolvingCode = false
            }
        default:
            cameraAuthorized = false
            permissionDenied = true
            isResolvingCode = false
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func announce(_ message: String.LocalizationValue) {
        UIAccessibility.post(
            notification: .announcement,
            argument: String(localized: message)
        )
    }
}

private struct QRScannerLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .tint(.white)
                Text("Wczytywanie menu…")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Wczytywanie menu…"))
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Brak dostępu do kamery"))
    }
}
