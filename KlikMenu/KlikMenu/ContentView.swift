import AVFoundation
import KlikMenuCore
import SwiftUI

struct ContentView: View {
    @State private var route: RestaurantMenuRoute?
    @State private var cameraAuthorized = false
    @State private var permissionDenied = false
    @State private var lastRejectedCode: String?
    @State private var debugInput = "bistro-klik"
    @State private var scannerResetID = UUID()

    var body: some View {
        NavigationStack {
            Group {
                if let route {
                    RestaurantMenuView(slug: route.slug)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Skanuj ponownie") {
                                    self.route = nil
                                    lastRejectedCode = nil
                                    scannerResetID = UUID()
                                }
                                .frame(minHeight: 44)
                            }
                        }
                } else {
                    scannerScreen
                }
            }
        }
        .klikMenuPreferredColorScheme()
        .task {
            await requestCameraAccess()
        }
    }

    private var scannerScreen: some View {
        ZStack {
            if cameraAuthorized {
                QRScannerView { code in
                    handleScannedCode(code)
                }
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
                    VStack(spacing: 12) {
                        Text("Brak dostępu do kamery. Włącz go w Ustawieniach, aby skanować kody QR.")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Button("Otwórz Ustawienia") {
                            openSettings()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.klikAccent)
                        .frame(minHeight: 44)
                    }
                    .padding()
                }

                #if DEBUG
                debugPanel
                #endif

                Spacer(minLength: 24)
            }
            .padding()
        }
        .accessibilityElement(children: .contain)
    }

    #if DEBUG
    private var debugPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug / Simulator")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.8))
            TextField("URL lub slug", text: $debugInput)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Testowy URL lub slug")
            Button("Otwórz przykładowe menu") {
                openDebugInput()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.klikAccent)
            .frame(minHeight: 44)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func openDebugInput() {
        let trimmed = debugInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if let parsed = RestaurantMenuURLParser.parse(trimmed) {
            route = parsed
            return
        }
        if let parsed = RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/\(trimmed)") {
            route = parsed
        }
    }
    #endif

    private func handleScannedCode(_ code: String) {
        if code == lastRejectedCode {
            scannerResetID = UUID()
            return
        }

        if let parsed = RestaurantMenuURLParser.parse(code) {
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
