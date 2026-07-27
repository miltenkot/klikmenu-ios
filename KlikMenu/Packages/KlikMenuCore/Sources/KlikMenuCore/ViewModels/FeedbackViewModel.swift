import Foundation
import Observation

@MainActor
@Observable
public final class FeedbackViewModel {
    public enum State: Sendable {
        case idle
        case submitting
        case success
        case error(LocalizedStringResource)
    }

    public var selectedWaiterID: String?
    public var rating = 0
    public var comment = "" {
        didSet {
            if comment.count > 1000 {
                comment = String(comment.prefix(1000))
            }
        }
    }

    public private(set) var state: State = .idle
    private let api: any KlikMenuAPIClient

    public init(api: any KlikMenuAPIClient) {
        self.api = api
    }

    public var canSubmit: Bool {
        selectedWaiterID != nil && (1...5).contains(rating) && state != .submitting
    }

    public func submit(slug: String) async {
        guard let waiterID = selectedWaiterID, canSubmit else { return }
        state = .submitting

        let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            _ = try await api.submitFeedback(
                slug: slug,
                request: FeedbackRequest(
                    waiterID: waiterID,
                    rating: rating,
                    comment: trimmed.isEmpty ? nil : trimmed
                )
            )
            state = .success
        } catch let error as APIError {
            state = .error(error.userFacingMessage)
        } catch {
            state = .error(APIError.network.userFacingMessage)
        }
    }
}

extension FeedbackViewModel.State: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.submitting, .submitting), (.success, .success):
            true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            String(localized: lhsMessage) == String(localized: rhsMessage)
        default:
            false
        }
    }
}
