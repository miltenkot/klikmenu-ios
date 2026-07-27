import KlikMenuCore
import SwiftUI

struct ContentView: View {
    let initialURL: URL?

    @State private var route: RestaurantMenuRoute?
    @State private var invalidURLMessage: String?

    var body: some View {
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
                MenuLoadingView()
            }
        }
        .klikMenuPreferredColorScheme()
        .onAppear {
            if let initialURL {
                apply(url: initialURL)
            }
        }
        .onOpenURL { url in
            apply(url: url)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            if let url = activity.webpageURL {
                apply(url: url)
            }
        }
    }

    private func apply(url: URL) {
        if let parsed = RestaurantMenuURLParser.parse(url) {
            route = parsed
            invalidURLMessage = nil
        } else {
            route = nil
            invalidURLMessage =
                "Link musi mieć postać https://app.klikmenu.pl/menu/{slug}."
        }
    }
}

#Preview {
    ContentView(initialURL: URL(string: "https://app.klikmenu.pl/menu/bistro-klik"))
}
