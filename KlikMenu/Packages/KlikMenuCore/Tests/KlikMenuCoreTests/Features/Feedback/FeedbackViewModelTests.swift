import Foundation
import Testing
import KlikMenuCore

private final class FeedbackAPI: KlikMenuAPIClient, @unchecked Sendable {
    var shouldRateLimit = false
    var shouldFailServer = false
    private(set) var lastRequest: FeedbackRequest?

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        throw APIError.network
    }
    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig { throw APIError.network }
    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        lastRequest = request
        if shouldRateLimit {
            throw APIError.http(statusCode: 429, message: "Too many", code: "RATE_LIMIT")
        }
        if shouldFailServer {
            throw APIError.http(statusCode: 500, message: "boom", code: "INTERNAL")
        }
        return SubmitFeedbackResponseDTO(accepted: true)
    }
}

@Test @MainActor
func submitsValidFeedback() async {
    let api = FeedbackAPI()
    let model = FeedbackViewModel(api: api)
    model.selectedWaiterID = "w"
    model.rating = 5
    model.comment = "  Super  "
    await model.submit(slug: "r")
    #expect(model.state == .success)
    #expect(api.lastRequest?.waiterID == "w")
    #expect(api.lastRequest?.rating == 5)
    #expect(api.lastRequest?.comment == "Super")
}

@Test @MainActor
func requiresWaiterAndRatingBeforeSubmit() async {
    let model = FeedbackViewModel(api: FeedbackAPI())
    #expect(model.canSubmit == false)
    model.selectedWaiterID = "w"
    #expect(model.canSubmit == false)
    model.rating = 3
    #expect(model.canSubmit)
}

@Test @MainActor
func truncatesCommentToOneThousandCharacters() {
    let model = FeedbackViewModel(api: FeedbackAPI())
    model.comment = String(repeating: "a", count: 1005)
    #expect(model.comment.count == 1000)
}

@Test @MainActor
func mapsFeedbackRateLimit() async {
    let api = FeedbackAPI()
    api.shouldRateLimit = true
    let model = FeedbackViewModel(api: api)
    model.selectedWaiterID = "w"
    model.rating = 4
    await model.submit(slug: "r")
    guard case .error(let message) = model.state else {
        Issue.record("Expected error state")
        return
    }
    #expect(
        {
            var copy = message
            copy.locale = Locale(identifier: "pl")
            return String(localized: copy)
        }()
        .localizedCaseInsensitiveContains("zbyt wiele")
    )
}

@Test @MainActor
func mapsFeedbackServerError() async {
    let api = FeedbackAPI()
    api.shouldFailServer = true
    let model = FeedbackViewModel(api: api)
    model.selectedWaiterID = "w"
    model.rating = 2
    await model.submit(slug: "r")
    guard case .error(let message) = model.state else {
        Issue.record("Expected error state")
        return
    }
    #expect(
        {
            var copy = message
            copy.locale = Locale(identifier: "pl")
            return String(localized: copy)
        }()
        .isEmpty == false
    )
}

@Test @MainActor
func blocksSubmitWhileRequestInFlight() async {
    final class SlowAPI: KlikMenuAPIClient, @unchecked Sendable {
        func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
            throw APIError.network
        }
        func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig { throw APIError.network }
        func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
            try await Task.sleep(nanoseconds: 200_000_000)
            return SubmitFeedbackResponseDTO(accepted: true)
        }
    }

    let model = FeedbackViewModel(api: SlowAPI())
    model.selectedWaiterID = "w"
    model.rating = 5
    async let first: Void = model.submit(slug: "r")
    try? await Task.sleep(nanoseconds: 20_000_000)
    #expect(model.state == .submitting)
    #expect(model.canSubmit == false)
    await first
    #expect(model.state == .success)
}
