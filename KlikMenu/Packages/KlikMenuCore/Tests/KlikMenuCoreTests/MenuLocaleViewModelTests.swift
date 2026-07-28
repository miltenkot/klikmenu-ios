import Foundation
import Testing
import KlikMenuCore

private final class LocalePreferenceBox: @unchecked Sendable {
    var values: [String]

    init(_ values: [String]) {
        self.values = values
    }
}

private actor LocaleRecordingAPI: KlikMenuAPIClient {
    private(set) var menuLocales: [SupportedLocale] = []
    private var menuResults: [SupportedLocale: RestaurantMenu] = [:]
    private var holdFirstRequest = false
    private var pendingContinuations: [CheckedContinuation<RestaurantMenu, Error>] = []

    func configure(holdFirstRequest: Bool) {
        self.holdFirstRequest = holdFirstRequest
    }

    func setMenu(_ menu: RestaurantMenu, for locale: SupportedLocale) {
        menuResults[locale] = menu
    }

    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        menuLocales.append(locale)
        if holdFirstRequest, menuLocales.count == 1 {
            return try await withCheckedThrowingContinuation { continuation in
                pendingContinuations.append(continuation)
            }
        }
        if let menu = menuResults[locale] {
            return menu
        }
        throw APIError.network
    }

    func resumePending(with menu: RestaurantMenu) {
        let pending = pendingContinuations
        pendingContinuations.removeAll()
        for continuation in pending {
            continuation.resume(returning: menu)
        }
    }

    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig {
        FeedbackConfig(enabled: false, restaurantName: "R", waiters: [])
    }

    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO {
        SubmitFeedbackResponseDTO(accepted: true)
    }
}

private func menu(name: String, locale: SupportedLocale) -> RestaurantMenu {
    RestaurantMenu(
        id: "r",
        name: name,
        slug: "bistro",
        description: nil,
        address: nil,
        phone: nil,
        currency: "PLN",
        heroImageURL: nil,
        requestedLocale: locale,
        resolvedLocale: locale,
        baseLocale: .pl,
        availableLocales: [.pl, .en],
        categories: [
            MenuCategory(
                id: "c",
                name: "Food",
                description: nil,
                position: 0,
                items: [
                    MenuItem(
                        id: "i-\(locale.rawValue)",
                        categoryID: "c",
                        subcategoryID: nil,
                        name: name,
                        description: nil,
                        ingredients: nil,
                        servingSize: nil,
                        allergens: [],
                        price: "10.00",
                        dietaryType: .none,
                        position: 0,
                        isAvailable: true,
                        imageURL: nil
                    )
                ],
                subcategories: []
            )
        ]
    )
}

@Test @MainActor
func reloadsMenuWhenAppLanguageChanges() async {
    let api = LocaleRecordingAPI()
    await api.setMenu(menu(name: "PL dish", locale: .pl), for: .pl)
    await api.setMenu(menu(name: "EN dish", locale: .en), for: .en)

    let preferences = LocalePreferenceBox(["pl-PL"])
    let model = RestaurantMenuViewModel(
        api: api,
        languageResolver: AppLanguageResolver { preferences.values }
    )

    await model.load(slug: "bistro")
    #expect(model.loadedLocale == .pl)
    #expect(model.menu?.name == "PL dish")

    preferences.values = ["en-US"]
    await model.reloadIfLanguageChanged()
    #expect(model.loadedLocale == .en)
    #expect(model.menu?.name == "EN dish")

    let locales = await api.menuLocales
    #expect(locales == [.pl, .en])
}

@Test @MainActor
func staleMenuResponseDoesNotOverwriteNewerLocale() async {
    let api = LocaleRecordingAPI()
    await api.configure(holdFirstRequest: true)
    await api.setMenu(menu(name: "EN dish", locale: .en), for: .en)

    let preferences = LocalePreferenceBox(["pl"])
    let model = RestaurantMenuViewModel(
        api: api,
        languageResolver: AppLanguageResolver { preferences.values }
    )

    let firstLoad = Task {
        await model.load(slug: "bistro")
    }
    try? await Task.sleep(for: .milliseconds(40))

    preferences.values = ["en"]
    await model.reloadIfLanguageChanged()
    #expect(model.menu?.name == "EN dish")
    #expect(model.loadedLocale == .en)

    await api.resumePending(with: menu(name: "PL late", locale: .pl))
    await firstLoad.value

    #expect(model.menu?.name == "EN dish")
    #expect(model.loadedLocale == .en)
}

@Test @MainActor
func keepsSeparateInMemoryStatePerSlugAndLocale() async {
    let api = LocaleRecordingAPI()
    await api.setMenu(menu(name: "PL A", locale: .pl), for: .pl)
    await api.setMenu(menu(name: "EN A", locale: .en), for: .en)

    let polish = RestaurantMenuViewModel(
        api: api,
        languageResolver: AppLanguageResolver(preferredLocalizations: ["pl"])
    )
    let english = RestaurantMenuViewModel(
        api: api,
        languageResolver: AppLanguageResolver(preferredLocalizations: ["en"])
    )

    await polish.load(slug: "alpha")
    await english.load(slug: "alpha")

    #expect(polish.menu?.name == "PL A")
    #expect(english.menu?.name == "EN A")
    #expect(polish.loadedLocale == .pl)
    #expect(english.loadedLocale == .en)
}
