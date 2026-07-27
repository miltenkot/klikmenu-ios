import Testing
import KlikMenuCore

private struct FeedbackAPI: KlikMenuAPIClient {
    var shouldRateLimit = false

    func fetchMenu(slug: String) async throws -> RestaurantMenu { throw APIError.network }
    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig { throw APIError.network }
    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        if shouldRateLimit {
            throw APIError.http(statusCode: 429, message: "Too many", code: "RATE_LIMIT")
        }
        #expect(request.waiterID == "w")
        #expect(request.rating == 5)
        return SubmitFeedbackResponseDTO(accepted: true)
    }
}

@Test @MainActor
func submitsValidFeedback() async {
    let model = FeedbackViewModel(api: FeedbackAPI())
    model.selectedWaiterID = "w"
    model.rating = 5
    await model.submit(slug: "r")
    #expect(model.state == .success)
}

@Test @MainActor
func mapsFeedbackRateLimit() async {
    var api = FeedbackAPI()
    api.shouldRateLimit = true
    let model = FeedbackViewModel(api: api)
    model.selectedWaiterID = "w"
    model.rating = 4
    await model.submit(slug: "r")
    guard case .error(let message) = model.state else {
        Issue.record("Expected error state")
        return
    }
    #expect(String(localized: message).localizedCaseInsensitiveContains("zbyt wiele"))
}
