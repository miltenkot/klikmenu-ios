import KlikMenuCore

actor CancellationMenuAPI: KlikMenuAPIClient {
    let menuReturnsImmediately: Bool
    private(set) var menuStarted = false
    private(set) var feedbackStarted = false
    private(set) var menuCancelled = false
    private(set) var feedbackCancelled = false

    init(menuReturnsImmediately: Bool) {
        self.menuReturnsImmediately = menuReturnsImmediately
    }

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        menuStarted = true
        if !menuReturnsImmediately {
            do {
                // Bounded so a regression fails instead of hanging the test run.
                try await Task.sleep(for: .seconds(5))
            } catch {
                menuCancelled = Task.isCancelled
                throw error
            }
        }
        return emptyMenu(slug: slug)
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig {
        feedbackStarted = true
        do {
            try await Task.sleep(for: .seconds(5))
        } catch {
            feedbackCancelled = Task.isCancelled
            throw error
        }
        return FeedbackConfig(enabled: false, restaurantName: slug, waiters: [])
    }

    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        throw APIError.network
    }
}
