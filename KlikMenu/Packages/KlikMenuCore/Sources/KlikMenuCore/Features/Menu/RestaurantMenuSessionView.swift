import SwiftUI

/// Shared menu entry used by the App Clip (invocation URL) and the full app (QR / debug / deep link).
/// Once a route is set, both targets render the same `RestaurantMenuView`.
public struct RestaurantMenuSessionView<Idle: View>: View {
    @Binding private var route: RestaurantMenuRoute?
    @State private var invalidURLMessage: String?

    private let initialURL: URL?
    private let handlesSystemInvocation: Bool
    @ViewBuilder private let idle: Idle

    public init(
        route: Binding<RestaurantMenuRoute?>,
        initialURL: URL? = nil,
        handlesSystemInvocation: Bool = false,
        @ViewBuilder idle: () -> Idle
    ) {
        _route = route
        self.initialURL = initialURL
        self.handlesSystemInvocation = handlesSystemInvocation
        self.idle = idle()
    }

    public var body: some View {
        Group {
            if let route {
                RestaurantMenuView(slug: route.slug)
            } else if let invalidURLMessage {
                ContentUnavailableView(
                    "Nieprawidłowy link",
                    systemImage: "link",
                    description: Text(invalidURLMessage)
                )
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
