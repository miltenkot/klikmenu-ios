import KlikMenuCore

struct MenuAPI: KlikMenuAPIClient {
    var feedback: FeedbackConfig

    init(feedback: FeedbackConfig) {
        self.feedback = feedback
    }

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        RestaurantMenu(
            id: "r",
            name: "R",
            slug: slug,
            description: nil,
            address: nil,
            phone: nil,
            currency: "PLN",
            heroImageURL: nil,
            categories: []
        )
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig { feedback }

    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        SubmitFeedbackResponseDTO(accepted: true)
    }
}
