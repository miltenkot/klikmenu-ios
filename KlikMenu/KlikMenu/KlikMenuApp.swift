import KlikMenuCore
import SwiftUI

@main
struct KlikMenuApp: App {
    init() {
        ImageURLCacheConfiguration.configureIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
