import KlikMenuCore

actor DelayedFeedbackAPI: KlikMenuAPIClient {
    private var pendingFeedback: CheckedContinuation<FeedbackConfig, Never>?

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        emptyMenu(slug: slug)
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig {
        if slug == "old" {
            // Deliberately ignore cancellation to simulate a response already in flight.
            return await withCheckedContinuation { pendingFeedback = $0 }
        }
        return FeedbackConfig(enabled: false, restaurantName: slug, waiters: [])
    }

    var isFeedbackPending: Bool { pendingFeedback != nil }

    func releaseFeedback() {
        pendingFeedback?.resume(returning: FeedbackConfig(
            enabled: true, restaurantName: "old",
            waiters: [PublicWaiter(id: "old-waiter", name: "Old", photoURL: nil)]
        ))
        pendingFeedback = nil
    }

    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        throw APIError.network
    }
}
