import Observation
import SwiftUI

public struct ServiceFeedbackSheet: View {
    public let slug: String
    public let config: FeedbackConfig
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FeedbackViewModel

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
                    thankYouView
                default:
                    formView(model: model)
                }
            }
            .navigationTitle("Oceń obsługę")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zamknij") { dismiss() }
                        .frame(minHeight: 44)
                }
            }
        }
    }

    private var thankYouView: some View {
        VStack(spacing: 18) {
            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.klikAccent)
                .accessibilityHidden(true)
            Text("Dziękujemy!")
                .font(.system(.title, design: .serif).weight(.bold))
            Text("Twoja opinia została wysłana.")
                .foregroundStyle(Color.klikMuted)
                .multilineTextAlignment(.center)
            Button("Zamknij") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(Color.klikAccent)
                .frame(minHeight: 44)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.klikPageBackground.ignoresSafeArea())
        .accessibilityElement(children: .combine)
    }

    private func formView(model: FeedbackViewModel) -> some View {
        @Bindable var model = model
        return Form {
            Section("Wybierz kelnera") {
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
                                    .accessibilityLabel("Wybrany")
                            }
                        }
                        .contentShape(Rectangle())
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Kelner \(waiter.name)")
                    .accessibilityAddTraits(
                        model.selectedWaiterID == waiter.id ? .isSelected : []
                    )
                }
            }

            Section("Ocena") {
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            model.rating = model.rating == star ? 0 : star
                        } label: {
                            Image(systemName: star <= model.rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundStyle(Color.klikAccent)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("\(star) z 5 gwiazdek")
                        .accessibilityAddTraits(star == model.rating ? .isSelected : [])
                        .accessibilityHint(
                            model.rating == star
                                ? "Dwukrotnie stuknij, aby wyczyścić ocenę"
                                : "Ustaw ocenę na \(star)"
                        )
                    }
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(
                    model.rating > 0
                        ? "Ocena \(model.rating) z 5 gwiazdek"
                        : "Brak oceny"
                )
            }

            Section("Komentarz (opcjonalnie)") {
                TextField(
                    "Dodaj komentarz",
                    text: $model.comment,
                    axis: .vertical
                )
                .lineLimit(5...)
                .accessibilityLabel("Komentarz do opinii")
                Text("\(model.comment.count)/1000")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("\(model.comment.count) z 1000 znaków")
            }

            if case .error(let message) = model.state {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Błąd: \(message)")
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
                        Text("Wyślij opinię")
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
