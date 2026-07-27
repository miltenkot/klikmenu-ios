import SwiftUI

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
