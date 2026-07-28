import SwiftUI

extension View {
    /// Grows the view on ScrollView overscroll (pull-down), anchored at the bottom.
    /// See: https://nilcoalescing.com/blog/StretchyHeaderInSwiftUI/
    func stretchy() -> some View {
        visualEffect { effect, geometry in
            let currentHeight = geometry.size.height
            let scrollOffset = geometry.frame(in: .scrollView).minY
            let positiveOffset = max(0, scrollOffset)

            let scaleFactor = currentHeight > 0
                ? (currentHeight + positiveOffset) / currentHeight
                : 1

            return effect.scaleEffect(
                x: scaleFactor,
                y: scaleFactor,
                anchor: .bottom
            )
        }
    }
}
