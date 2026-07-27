import SwiftUI

public struct MenuErrorView: View {
    public let message: String
    public let retry: () -> Void

    public init(message: String, retry: @escaping () -> Void) {
        self.message = message
        self.retry = retry
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Nie udało się wczytać menu", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Spróbuj ponownie", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(Color.klikAccent)
                .frame(minHeight: 44)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.klikPageBackground.ignoresSafeArea())
    }
}

public struct EmptyMenuView: View {
    public init() {}

    public var body: some View {
        ContentUnavailableView(
            "Menu jest puste",
            systemImage: "fork.knife",
            description: Text("Ta restauracja nie ma jeszcze dostępnych pozycji.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.klikPageBackground.ignoresSafeArea())
    }
}
