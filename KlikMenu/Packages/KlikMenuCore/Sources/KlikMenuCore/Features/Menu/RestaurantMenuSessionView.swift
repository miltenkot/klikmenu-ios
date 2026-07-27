import SwiftUI

/// Shared menu entry used by the App Clip (invocation URL) and the full app (QR / debug / deep link).
/// Once a route is set, both targets render the same `RestaurantMenuView`.
public struct RestaurantMenuSessionView<Idle: View>: View {
    @Binding private var route: RestaurantMenuRoute?
    @State private var invalidURLMessage: String?

    private let initialURL: URL?
    private let handlesSystemInvocation: Bool
    private let idle: () -> Idle

    public init(
        route: Binding<RestaurantMenuRoute?>,
        initialURL: URL? = nil,
        handlesSystemInvocation: Bool = false,
        @ViewBuilder idle: @escaping () -> Idle
    ) {
        _route = route
        self.initialURL = initialURL
        self.handlesSystemInvocation = handlesSystemInvocation
        self.idle = idle
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
                idle()
            }
        }
        .klikMenuPreferredColorScheme()
        .onAppear {
            if let initialURL {
                apply(url: initialURL)
            }
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

/// Resolves KlikMenu invocation payloads (App Clip URL, QR code, debug slug).
public enum RestaurantMenuInvocation {
    public static let invalidLinkMessage =
        "Link musi mieć postać https://app.klikmenu.pl/menu/{slug}."

    public static func route(from raw: String) -> RestaurantMenuRoute? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let parsed = RestaurantMenuURLParser.parse(trimmed) {
            return parsed
        }
        guard !trimmed.isEmpty, !trimmed.contains("://") else { return nil }
        return RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/\(trimmed)")
    }

    public static func route(from url: URL) -> RestaurantMenuRoute? {
        RestaurantMenuURLParser.parse(url)
    }
}

private struct MenuInvocationEventsModifier: ViewModifier {
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
