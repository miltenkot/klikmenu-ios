import Observation
import SwiftUI

struct ServiceFeedbackFormView: View {
    let slug: String
    let config: FeedbackConfig
    @Bindable var model: FeedbackViewModel
    @FocusState.Binding var isCommentFocused: Bool

    var body: some View {
        Form {
            Section {
                ForEach(config.waiters) { waiter in
                    FeedbackWaiterRowView(
                        waiter: waiter,
                        isSelected: model.selectedWaiterID == waiter.id
                    ) {
                        model.selectedWaiterID = waiter.id
                    }
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
}

private struct FeedbackWaiterRowView: View {
    let waiter: PublicWaiter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                FeedbackWaiterAvatarView(waiter: waiter)
                Text(waiter.name)
                    .foregroundStyle(Color.klikText)
                Spacer()
                if isSelected {
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
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
