import KlikMenuCore
import SwiftUI
import UIKit

@main
struct KlikMenuApp: App {
    init() {
        ImageURLCacheConfiguration.configureIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
