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
                    formView(model: model)
                }
            }
            .navigationTitle(Text("Oceń obsługę", bundle: #bundle))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringResource("Zamknij", bundle: #bundle)) { dismiss() }
                        .frame(minHeight: 44)
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

    private func formView(model: FeedbackViewModel) -> some View {
        @Bindable var model = model
        return Form {
            Section {
                ForEach(config.waiters) { waiter in
                    Button {
                        model.selectedWaiterID = waiter.id
                    } label: {
                        HStack(spacing: 12) {
                            waiterAvatar(waiter)
                            Text(waiter.name)
                                .foregroundStyle(Color.klikText)
                            Spacer()
                            if model.selectedWaiterID == waiter.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.klikAccent)
                                    .accessibilityLabel(Text("Wybrany", bundle: #bundle))
                            }
                        }
                        .contentShape(Rectangle())
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Kelner \(waiter.name)", bundle: #bundle))
                    .accessibilityAddTraits(
                        model.selectedWaiterID == waiter.id ? .isSelected : []
                    )
                }
            } header: {
                Text("Wybierz kelnera", bundle: #bundle)
            }

            Section {
                FeedbackStarRatingControl(rating: $model.rating)
            } header: {
                Text("Ocena", bundle: #bundle)
            }

            Section {
                TextField(
                    text: $model.comment,
                    prompt: Text("Dodaj komentarz", bundle: #bundle),
                    axis: .vertical
                ) {
                    Text("Dodaj komentarz", bundle: #bundle)
                }
                .lineLimit(5...)
                .focused($isCommentFocused)
                .accessibilityLabel(Text("Komentarz do opinii", bundle: #bundle))
                Text(verbatim: "\(model.comment.count)/1000")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(Text("\(model.comment.count) z 1000 znaków", bundle: #bundle))
            } header: {
                Text("Komentarz (opcjonalnie)", bundle: #bundle)
            }

            if case .error(let message) = model.state {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                        .accessibilityLabel(
                            Text("Błąd: \(String(localized: message))", bundle: #bundle)
                        )
                }
            }

            Section {
                Button {
                    Task { await model.submit(slug: slug) }
                } label: {
                    if model.state == .submitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Wyślij opinię", bundle: #bundle)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!model.canSubmit)
                .frame(minHeight: 44)
            }
        }
    }

    @ViewBuilder
    private func waiterAvatar(_ waiter: PublicWaiter) -> some View {
        if waiter.photoURL != nil {
            RemoteImageView(url: waiter.photoURL)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.klikBrand.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(waiter.initial)
                        .font(.headline)
                        .foregroundStyle(Color.klikBrand)
                }
                .accessibilityHidden(true)
        }
    }
}

private struct FeedbackStarRatingControl: View {
    @Binding var rating: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                let isFilled = star <= rating
                Button {
                    rating = rating == star ? 0 : star
                } label: {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundStyle(isFilled ? Color.klikAccent : Color.klikAccent.opacity(0.22))
                        .scaleEffect(isFilled ? 1 : 0.92)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(Text("\(star) z 5 gwiazdek", bundle: #bundle))
                .accessibilityAddTraits(star == rating ? .isSelected : [])
                .accessibilityHint(
                    rating == star
                        ? Text("Dwukrotnie stuknij, aby wyczyścić ocenę", bundle: #bundle)
                        : Text("Ustaw ocenę na \(star)", bundle: #bundle)
                )
            }
            Spacer(minLength: 0)
        }
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: rating)
        .sensoryFeedback(.selection, trigger: rating)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            rating > 0
                ? Text("Ocena \(rating) z 5 gwiazdek", bundle: #bundle)
                : Text("Brak oceny", bundle: #bundle)
        )
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
