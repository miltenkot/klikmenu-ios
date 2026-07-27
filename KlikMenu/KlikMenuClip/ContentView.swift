import KlikMenuCore
import SwiftUI

struct ContentView: View {
    let initialURL: URL?

    @State private var route: RestaurantMenuRoute?

    var body: some View {
        RestaurantMenuSessionView(
            route: $route,
            initialURL: initialURL,
            handlesSystemInvocation: true
        ) {
            MenuLoadingView()
        }
    }
}

#Preview {
    ContentView(initialURL: URL(string: "https://app.klikmenu.pl/menu/bistro-klik"))
}
