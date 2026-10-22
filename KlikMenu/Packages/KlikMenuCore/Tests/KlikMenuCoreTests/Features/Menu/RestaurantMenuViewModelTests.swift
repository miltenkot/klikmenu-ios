import Testing
import KlikMenuCore

@Suite
@MainActor
struct RestaurantMenuViewModelTests {
    @Test
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

    @Test
    func hidesFeedbackWhenDisabled() async {
        let model = RestaurantMenuViewModel(
            api: MenuAPI(
                feedback: FeedbackConfig(enabled: false, restaurantName: "R", waiters: [])
            )
        )
        await model.load(slug: "r")
        #expect(model.showFeedbackButton == false)
    }

    @Test
    func hidesFeedbackWhenWaitersEmpty() async {
        let model = RestaurantMenuViewModel(
            api: MenuAPI(
                feedback: FeedbackConfig(enabled: true, restaurantName: "R", waiters: [])
            )
        )
        await model.load(slug: "r")
        #expect(model.showFeedbackButton == false)
    }

    @Test
    func showsNotFoundState() async {
        let model = RestaurantMenuViewModel(api: MissingMenuAPI())
        await model.load(slug: "missing")
        #expect(model.state == .notFound)
    }

    @Test
    func staleFeedbackDoesNotOverwriteNewRestaurant() async {
        let api = DelayedFeedbackAPI()
        let model = RestaurantMenuViewModel(
            api: api, languageResolver: AppLanguageResolver(preferredLocalizations: ["pl"])
        )
        let firstLoad = Task { await model.load(slug: "old") }

        // Wait for the actual intermediate state, not an arbitrary sleep duration.
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while ContinuousClock.now < deadline {
            if model.menu?.slug == "old", await api.isFeedbackPending { break }
            await Task.yield()
        }
        let reachedPendingFeedback = model.menu?.slug == "old" && model.state == .loading
        #expect(reachedPendingFeedback)
        #expect(await api.isFeedbackPending)

        await model.load(slug: "new")
        #expect(model.feedbackConfig?.restaurantName == "new")

        await api.releaseFeedback()
        await firstLoad.value

        #expect(model.menu?.slug == "new")
        #expect(model.loadedLocale == .pl)
        #expect(model.state == .empty)
        #expect(model.feedbackConfig?.restaurantName == "new")
        #expect(!model.showFeedbackButton)
    }
}
