import SwiftUI

struct MenuInvocationEventsModifier: ViewModifier {
    let isEnabled: Bool
    let onURL: (URL) -> Void

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .onOpenURL(perform: onURL)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    if let url = activity.webpageURL {
                        onURL(url)
                    }
                }
        } else {
            content
        }
    }
}
