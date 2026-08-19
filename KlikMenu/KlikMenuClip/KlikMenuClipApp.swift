import KlikMenuCore
import SwiftUI

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
        }
    }
}
