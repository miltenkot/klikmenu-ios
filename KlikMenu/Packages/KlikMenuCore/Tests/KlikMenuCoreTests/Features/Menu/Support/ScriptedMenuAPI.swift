import Testing
import KlikMenuCore

actor ScriptedMenuAPI: KlikMenuAPIClient {
    private var results: [Result<RestaurantMenu, Error>]
    private let feedbackFails: Bool
    private(set) var slugs: [String] = []
    private(set) var locales: [SupportedLocale] = []

    init(_ results: [Result<RestaurantMenu, Error>], feedbackFails: Bool = false) {
        self.results = results
        self.feedbackFails = feedbackFails
    }

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        slugs.append(slug)
        locales.append(locale)
        guard !results.isEmpty else {
            Issue.record("Unexpected menu request")
            throw APIError.network
        }
        return try results.removeFirst().get()
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig {
        if feedbackFails { throw APIError.network }
        return FeedbackConfig(enabled: false, restaurantName: slug, waiters: [])
    }

    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        throw APIError.network
    }
}
