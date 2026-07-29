import Testing
import KlikMenuCore

private struct MenuAPI: KlikMenuAPIClient {
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

private struct MissingMenuAPI: KlikMenuAPIClient {
    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        throw APIError.notFound
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig { throw APIError.notFound }
    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        throw APIError.network
    }
}

@Test @MainActor
func showsEmptyStateAndFeedback() async {
    let model = RestaurantMenuViewModel(
        api: MenuAPI(
            feedback: FeedbackConfig(
                enabled: true,
                restaurantName: "R",
                waiters: [PublicWaiter(id: "w", name: "W", photoURL: nil)]
            )
        )
    )
    await model.load(slug: "r")
    #expect(model.state == .empty)
    #expect(model.showFeedbackButton)
}

@Test @MainActor
func hidesFeedbackWhenDisabled() async {
    let model = RestaurantMenuViewModel(
        api: MenuAPI(
            feedback: FeedbackConfig(enabled: false, restaurantName: "R", waiters: [])
        )
    )
    await model.load(slug: "r")
    #expect(model.showFeedbackButton == false)
}

@Test @MainActor
func hidesFeedbackWhenWaitersEmpty() async {
    let model = RestaurantMenuViewModel(
        api: MenuAPI(
            feedback: FeedbackConfig(enabled: true, restaurantName: "R", waiters: [])
        )
    )
    await model.load(slug: "r")
    #expect(model.showFeedbackButton == false)
}

@Test @MainActor
func showsNotFoundState() async {
    let model = RestaurantMenuViewModel(api: MissingMenuAPI())
    await model.load(slug: "missing")
    #expect(model.state == .notFound)
}
