import SwiftUI

#if canImport(UIKit)
import UIKit

/// Reports the key window's top safe-area inset (Dynamic Island / notch / status bar).
struct WindowSafeAreaTopReader: UIViewRepresentable {
    @Binding var topInset: CGFloat

    func makeUIView(context: Context) -> SafeAreaTopObservingView {
        let view = SafeAreaTopObservingView()
        view.isUserInteractionEnabled = false
        view.onInsetChange = { inset in
            Self.apply(inset: inset, to: $topInset)
        }
        return view
    }

    func updateUIView(_ uiView: SafeAreaTopObservingView, context: Context) {
        uiView.onInsetChange = { inset in
            Self.apply(inset: inset, to: $topInset)
        }
        // Do not call `reportInset()` here — it would write SwiftUI state during
        // the view update. Layout / window callbacks publish the value instead.
    }

    private static func apply(inset: CGFloat, to topInset: Binding<CGFloat>) {
        let resolved = inset > 0 ? inset : LayoutMetrics.fallbackTopSafeAreaInset
        guard abs(topInset.wrappedValue - resolved) > 0.5 else { return }

        // Defer past the current update/layout pass to avoid
        // "Modifying state during view update".
        DispatchQueue.main.async {
            guard abs(topInset.wrappedValue - resolved) > 0.5 else { return }
            topInset.wrappedValue = resolved
        }
    }
}

final class SafeAreaTopObservingView: UIView {
    var onInsetChange: ((CGFloat) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        reportInset()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reportInset()
    }

    func reportInset() {
        let inset = window?.safeAreaInsets.top ?? safeAreaInsets.top
        onInsetChange?(inset)
    }
}
#else
struct WindowSafeAreaTopReader: View {
    @Binding var topInset: CGFloat

    var body: some View {
        Color.clear
            .accessibilityHidden(true)
    }
}
#endif
