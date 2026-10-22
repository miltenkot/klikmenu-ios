import Testing
import KlikMenuCore

@Suite @MainActor
struct RestaurantMenuRecoveryTests {
    private func model(api: any KlikMenuAPIClient, language: String = "pl") -> RestaurantMenuViewModel {
        RestaurantMenuViewModel(
            api: api,
            languageResolver: AppLanguageResolver(preferredLocalizations: [language])
        )
    }

    @Test(arguments: [APIError.network, .decoding, .http(statusCode: 503, message: "", code: nil)])
    func mapsMenuErrorsAndClearsPreviousMenu(error: APIError) async {
        let api = ScriptedMenuAPI([.success(emptyMenu()), .failure(error)])
        let model = model(api: api)
        await model.load(slug: "bistro")
        #expect(model.menu != nil)

        await model.retry()

        #expect(model.state == .error(error.userFacingMessage))
        #expect(model.menu == nil)
        #expect(model.loadedLocale == nil)
    }

    @Test func mapsUnexpectedErrorToNetworkError() async {
        let model = model(api: ScriptedMenuAPI([.failure(UnexpectedError())]))
        await model.load(slug: "bistro")
        #expect(model.state == .error(APIError.network.userFacingMessage))
        #expect(model.menu == nil)
        #expect(model.loadedLocale == nil)
    }

    @Test func retryRecoversUsingTheSameSlug() async {
        let api = ScriptedMenuAPI([.failure(APIError.network), .success(emptyMenu())])
        let model = model(api: api)
        await model.load(slug: "bistro")
        #expect(model.state == .error(APIError.network.userFacingMessage))

        await model.retry()

        #expect(model.state == .empty)
        #expect(model.menu?.slug == "bistro")
        #expect(model.loadedLocale == .pl)
        #expect(await api.slugs == ["bistro", "bistro"])
    }

    @Test func retryAndLanguageReloadBeforeFirstLoadDoNotRequestMenu() async {
        let api = ScriptedMenuAPI([])
        let model = model(api: api)
        await model.retry()
        await model.reloadIfLanguageChanged()
        #expect(await api.slugs.isEmpty)
        #expect(model.state == .loading)
    }

    @Test func unchangedLanguageDoesNotReload() async {
        let api = ScriptedMenuAPI([.success(emptyMenu())])
        let model = model(api: api)
        await model.load(slug: "bistro")
        await model.reloadIfLanguageChanged()
        #expect(await api.locales == [.pl])
    }

    @Test func feedbackFailureDoesNotFailMenuLoad() async {
        let api = ScriptedMenuAPI([.success(emptyMenu())], feedbackFails: true)
        let model = model(api: api)
        await model.load(slug: "bistro")
        #expect(model.state == .empty)
        #expect(model.menu?.slug == "bistro")
        #expect(model.feedbackConfig == nil)
        #expect(!model.showFeedbackButton)
    }

    @Test(arguments: [false, true])
    func cancellationDoesNotBecomeAnError(useAPIError: Bool) async {
        let error: any Error = useAPIError ? APIError.cancelled : CancellationError()
        let model = model(api: ScriptedMenuAPI([.failure(error)]))
        await model.load(slug: "bistro")
        #expect(model.state == .loading)
        #expect(model.menu == nil)
        #expect(model.loadedLocale == nil)
    }

    @Test func reportsFailureOfPolishFallback() async {
        let unsupported = APIError.http(statusCode: 400, message: "", code: "UNSUPPORTED_LOCALE")
        let api = ScriptedMenuAPI([.failure(unsupported), .failure(APIError.network)])
        let model = model(api: api, language: "en")
        await model.load(slug: "bistro")
        #expect(await api.locales == [.en, .pl])
        #expect(model.state == .error(APIError.network.userFacingMessage))
        #expect(model.menu == nil)
        #expect(model.loadedLocale == nil)
    }

    @Test func unsupportedPolishDoesNotRetryPolishAgain() async {
        let unsupported = APIError.http(statusCode: 400, message: "", code: "UNSUPPORTED_LOCALE")
        let api = ScriptedMenuAPI([.failure(unsupported)])
        let model = model(api: api)
        await model.load(slug: "bistro")
        #expect(await api.locales == [.pl])
        #expect(model.state == .error(unsupported.userFacingMessage))
    }

    @Test func ordinaryErrorDoesNotTriggerLanguageFallback() async {
        let api = ScriptedMenuAPI([.failure(APIError.network)])
        let model = model(api: api, language: "en")
        await model.load(slug: "bistro")
        #expect(await api.locales == [.en])
        #expect(model.state == .error(APIError.network.userFacingMessage))
    }
}
