import SwiftUI

/// Shared menu entry used by the App Clip (invocation URL) and the full app (QR / debug / deep link).
/// Once a route is set, both targets render the same `RestaurantMenuView`.
public struct RestaurantMenuSessionView<Idle: View>: View {
    @Binding private var route: RestaurantMenuRoute?
    @State private var invalidURLMessage: LocalizedStringResource?

    private let initialURL: URL?
    private let handlesSystemInvocation: Bool
    private let onOrderBarVisibilityChanged: ((Bool) -> Void)?
    @ViewBuilder private let idle: Idle

    public init(
        route: Binding<RestaurantMenuRoute?>,
        initialURL: URL? = nil,
        handlesSystemInvocation: Bool = false,
        onOrderBarVisibilityChanged: ((Bool) -> Void)? = nil,
        @ViewBuilder idle: () -> Idle
    ) {
        _route = route
        self.initialURL = initialURL
        self.handlesSystemInvocation = handlesSystemInvocation
        self.onOrderBarVisibilityChanged = onOrderBarVisibilityChanged
        self.idle = idle()
    }

    public var body: some View {
        Group {
            if let route {
                RestaurantMenuView(
                    slug: route.slug,
                    onOrderBarVisibilityChanged: onOrderBarVisibilityChanged
                )
            } else if let invalidURLMessage {
                ContentUnavailableView {
                    Label {
                        Text("Nieprawidłowy link", bundle: #bundle)
                    } icon: {
                        Image(systemName: "link")
                    }
                } description: {
                    Text(invalidURLMessage)
                }
                .padding()
            } else {
                idle
            }
        }
        .klikMenuPreferredColorScheme()
        .task(id: initialURL?.absoluteString) {
            guard let initialURL else { return }
            apply(url: initialURL)
        }
        .onChange(of: route?.slug) { _, newSlug in
            if newSlug != nil {
                invalidURLMessage = nil
            }
        }
        .modifier(
            MenuInvocationEventsModifier(isEnabled: handlesSystemInvocation) { url in
                apply(url: url)
            }
        )
    }

    private func apply(url: URL) {
        if let parsed = RestaurantMenuInvocation.route(from: url) {
            route = parsed
            invalidURLMessage = nil
        } else {
            route = nil
            invalidURLMessage = RestaurantMenuInvocation.invalidLinkMessage
        }
    }
}
