import Observation
import SwiftUI

struct ServiceFeedbackFormView: View {
    private enum ScrollTarget {
        case comment
    }

    let slug: String
    let config: FeedbackConfig
    @Bindable var model: FeedbackViewModel
    @FocusState.Binding var isCommentFocused: Bool
    @ScaledMetric(relativeTo: .body) private var commentEditorHeight = 110

    var body: some View {
        ScrollViewReader { proxy in
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
                    TextEditor(text: $model.comment)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .focused($isCommentFocused)
                        .frame(height: commentEditorHeight)
                        .overlay(alignment: .topLeading) {
                            if model.comment.isEmpty {
                                Text("Dodaj komentarz", bundle: #bundle)
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel(Text("Komentarz do opinii", bundle: #bundle))
                        .id(ScrollTarget.comment)
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
                        isCommentFocused = false
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
                    .tint(Color.klikAccent)
                    .disabled(!model.canSubmit)
                    .frame(minHeight: 44)
                }
            }
            .safeAreaPadding(.bottom, isCommentFocused ? 20 : 0)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: isCommentFocused) { _, focused in
                guard focused else { return }
                proxy.scrollTo(ScrollTarget.comment, anchor: .center)
            }
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            } action: { _ in
                // Reposition after the keyboard changes the available viewport.
                // TextEditor handles caret scrolling within its own fixed-height bounds.
                guard isCommentFocused else { return }
                proxy.scrollTo(ScrollTarget.comment, anchor: .center)
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
            .contentShape(.rect)
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Kelner \(waiter.name)", bundle: #bundle))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
