import SwiftUI

struct MenuInvocationEventsModifier: ViewModifier {
    let isEnabled: Bool
    let onURL: (URL) -> Void

    func body(content: Content) -> some View {
        // Keep modifiers unconditionally attached so cold-start App Clip /
        // universal-link activities are not dropped by a conditional view tree.
        content
            .onOpenURL { url in
                guard isEnabled else { return }
                onURL(url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                guard isEnabled, let url = activity.webpageURL else { return }
                onURL(url)
            }
    }
}
