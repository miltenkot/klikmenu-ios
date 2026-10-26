import KlikMenuCore

actor DelayedFeedbackAPI: KlikMenuAPIClient {
    private var pendingFeedback: CheckedContinuation<FeedbackConfig, Never>?
    private let categories: [MenuCategory]

    init(categories: [MenuCategory] = []) {
        self.categories = categories
    }

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        RestaurantMenu(
            id: slug, name: slug, slug: slug, description: nil, address: nil,
            phone: nil, currency: "PLN", heroImageURL: nil, categories: categories
        )
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
