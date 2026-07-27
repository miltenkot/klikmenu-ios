import SwiftUI

public struct MenuErrorView: View {
    public let message: LocalizedStringResource
    public let retry: () -> Void

    public init(message: LocalizedStringResource, retry: @escaping () -> Void) {
        self.message = message
        self.retry = retry
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text("Nie udało się wczytać menu", bundle: #bundle)
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
        } description: {
            Text(message)
        } actions: {
            Button(LocalizedStringResource("Spróbuj ponownie", bundle: #bundle), action: retry)
                .buttonStyle(.borderedProminent)
                .tint(Color.klikAccent)
                .frame(minHeight: 44)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.klikPageBackground.ignoresSafeArea() }
    }
}
