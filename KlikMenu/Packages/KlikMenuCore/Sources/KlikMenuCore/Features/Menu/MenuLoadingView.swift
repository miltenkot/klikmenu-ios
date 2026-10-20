import SwiftUI

public struct MenuLoadingView: View {
    public init() {}

    public var body: some View {
        ProgressView {
            Text("Ładujemy menu…", bundle: #bundle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
        }
        .progressViewStyle(.circular)
        .controlSize(.regular)
        .tint(.secondary)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background, ignoresSafeAreaEdges: .all)
    }
}

#Preview("Light") {
    MenuLoadingView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MenuLoadingView()
        .preferredColorScheme(.dark)
}

#Preview("Accessibility") {
    MenuLoadingView()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.locale, Locale(identifier: "pl"))
}
