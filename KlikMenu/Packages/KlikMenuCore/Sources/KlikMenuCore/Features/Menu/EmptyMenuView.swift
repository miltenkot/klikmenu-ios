import SwiftUI

public struct EmptyMenuView: View {
    public init() {}

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text("Menu jest puste", bundle: #bundle)
            } icon: {
                Image(systemName: "fork.knife")
            }
        } description: {
            Text("Ta restauracja nie ma jeszcze dostępnych pozycji.", bundle: #bundle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.klikPageBackground.ignoresSafeArea() }
    }
}
