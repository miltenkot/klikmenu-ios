import Observation
import SwiftUI

public struct ServiceFeedbackSheet: View {
    public let slug: String
    public let config: FeedbackConfig
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FeedbackViewModel
    @FocusState private var isCommentFocused: Bool

    public init(slug: String, config: FeedbackConfig, viewModel: FeedbackViewModel) {
        self.slug = slug
        self.config = config
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var model = viewModel
        NavigationStack {
            Group {
                switch model.state {
                case .success:
                    FeedbackThankYouView(onDismiss: dismiss.callAsFunction)
                default:
                    ServiceFeedbackFormView(
                        slug: slug,
                        config: config,
                        model: model,
                        isCommentFocused: $isCommentFocused
                    )
                }
            }
            .navigationTitle(Text("Oceń obsługę", bundle: #bundle))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if showsCloseToolbarButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(LocalizedStringResource("Zamknij", bundle: #bundle)) { dismiss() }
                            .frame(minHeight: 44)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(LocalizedStringResource("Gotowe", bundle: #bundle)) {
                        isCommentFocused = false
                    }
                }
            }
        }
    }

    private var showsCloseToolbarButton: Bool {
        if case .success = viewModel.state { return false }
        return true
    }
}

struct FeedbackThankYouView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.klikAccent)
                .accessibilityHidden(true)
            Text("Dziękujemy!", bundle: #bundle)
                .font(.system(.title, design: .serif).weight(.bold))
            Text("Twoja opinia została wysłana.", bundle: #bundle)
                .foregroundStyle(Color.klikMuted)
                .multilineTextAlignment(.center)
            Button(LocalizedStringResource("Zamknij", bundle: #bundle), action: onDismiss)
                .buttonStyle(.borderedProminent)
                .tint(Color.klikAccent)
                .frame(minHeight: 44)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.klikPageBackground.ignoresSafeArea() }
        .accessibilityElement(children: .combine)
    }
}
