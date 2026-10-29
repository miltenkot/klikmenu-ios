import KlikMenuCore
import SwiftUI
import UIKit

@main
struct KlikMenuClipApp: App {
    init() {
        ImageURLCacheConfiguration.configureIfNeeded()
    }
    private let launchInvocationURL: URL? = {
        if let raw = ProcessInfo.processInfo.environment["_XCAppClipURL"],
           let url = URL(string: raw) {
            return url
        }
        return nil
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(initialURL: launchInvocationURL)
                #if DEBUG
                .task {
                    for await _ in NotificationCenter.default.notifications(
                        named: UIApplication.didReceiveMemoryWarningNotification
                    ) {
                        guard !Task.isCancelled else { return }
                        print("⚠️ Memory warning received")
                    }
                }
                #endif
        }
    }
}
