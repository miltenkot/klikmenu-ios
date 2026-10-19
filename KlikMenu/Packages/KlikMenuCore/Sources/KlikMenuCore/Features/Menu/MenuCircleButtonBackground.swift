import SwiftUI

struct MenuCircleButtonBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Circle())
        } else {
            content.background(.regularMaterial, in: Circle())
        }
    }
}
