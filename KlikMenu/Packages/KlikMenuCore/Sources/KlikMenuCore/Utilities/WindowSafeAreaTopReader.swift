import SwiftUI
import UIKit

/// Reports the key window's top safe-area inset (Dynamic Island / notch / status bar).
struct WindowSafeAreaTopReader: UIViewRepresentable {
    @Binding var topInset: CGFloat

    func makeUIView(context: Context) -> SafeAreaTopObservingView {
        let view = SafeAreaTopObservingView()
        view.isUserInteractionEnabled = false
        view.onInsetChange = { inset in
            let resolved = inset > 0 ? inset : 59
            if abs(topInset - resolved) > 0.5 {
                topInset = resolved
            }
        }
        return view
    }

    func updateUIView(_ uiView: SafeAreaTopObservingView, context: Context) {
        uiView.onInsetChange = { inset in
            let resolved = inset > 0 ? inset : 59
            if abs(topInset - resolved) > 0.5 {
                topInset = resolved
            }
        }
        uiView.reportInset()
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
        DispatchQueue.main.async { [onInsetChange] in
            onInsetChange?(inset)
        }
    }
}
