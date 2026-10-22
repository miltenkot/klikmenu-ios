import KlikMenuCore

struct MissingMenuAPI: KlikMenuAPIClient {
    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        throw APIError.notFound
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig { throw APIError.notFound }
    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        throw APIError.network
    }
}
