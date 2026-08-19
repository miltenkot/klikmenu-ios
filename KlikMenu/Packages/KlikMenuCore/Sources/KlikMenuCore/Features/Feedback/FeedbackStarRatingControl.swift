import SwiftUI

struct FeedbackStarRatingControl: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                FeedbackStarButton(
                    star: star,
                    isFilled: star <= rating,
                    isSelected: star == rating,
                    action: { rating = rating == star ? 0 : star }
                )
            }
            Spacer(minLength: 0)
        }
        .sensoryFeedback(.selection, trigger: rating)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            rating > 0
                ? Text("Ocena \(rating) z 5 gwiazdek", bundle: #bundle)
                : Text("Brak oceny", bundle: #bundle)
        )
    }
}

private struct FeedbackStarButton: View {
    let star: Int
    let isFilled: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "star")
                .symbolVariant(isFilled ? .fill : .none)
                .font(.title2)
                .foregroundStyle(isFilled ? Color.klikAccent : Color.klikAccent.opacity(0.22))
                .frame(width: 44, height: 44)
                .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(Text("\(star) z 5 gwiazdek", bundle: #bundle))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(
            isSelected
                ? Text("Dwukrotnie stuknij, aby wyczyścić ocenę", bundle: #bundle)
                : Text("Ustaw ocenę na \(star)", bundle: #bundle)
        )
    }
}
