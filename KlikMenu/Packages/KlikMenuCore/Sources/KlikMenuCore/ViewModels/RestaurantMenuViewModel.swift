import Foundation
import Observation

@MainActor
@Observable
public final class RestaurantMenuViewModel {
    public enum State: Sendable {
        case loading
        case loaded
        case empty
        case notFound
        case error(LocalizedStringResource)
    }

    public private(set) var state: State = .loading
    public private(set) var menu: RestaurantMenu?
    public private(set) var feedbackConfig: FeedbackConfig?
    public private(set) var loadedLocale: SupportedLocale?

    private let api: any KlikMenuAPIClient
    private let languageResolver: AppLanguageResolver
    private var slug = ""
    private var loadTask: Task<Void, Never>?
    private var loadGeneration = 0

    public init(
        api: any KlikMenuAPIClient,
        languageResolver: AppLanguageResolver = AppLanguageResolver()
    ) {
        self.api = api
        self.languageResolver = languageResolver
    }

    public var showFeedbackButton: Bool {
        feedbackConfig?.isFeedbackAvailable == true
    }

    public func load(slug: String) async {
        await load(slug: slug, locale: languageResolver.resolve())
    }

    public func reloadIfLanguageChanged() async {
        guard !slug.isEmpty else { return }
        let locale = languageResolver.resolve()
        guard locale != loadedLocale else { return }
        await load(slug: slug, locale: locale)
    }

    public func retry() async {
        guard !slug.isEmpty else { return }
        await load(slug: slug, locale: languageResolver.resolve())
    }

    public func makeFeedbackViewModel() -> FeedbackViewModel {
        FeedbackViewModel(api: api)
    }

    private func load(slug: String, locale: SupportedLocale) async {
        loadTask?.cancel()
        loadGeneration += 1
        let generation = loadGeneration

        self.slug = slug
        state = .loading
        // Avoid showing a previous language while the new locale loads.
        if loadedLocale != locale {
            menu = nil
            feedbackConfig = nil
        }
        loadedLocale = nil

        let task = Task {
            await performLoad(slug: slug, locale: locale, generation: generation)
        }
        loadTask = task
        await task.value
    }

    private func performLoad(slug: String, locale: SupportedLocale, generation: Int) async {
        do {
            async let menuTask = api.fetchMenu(slug: slug, locale: locale)
            async let feedbackTask = fetchFeedbackConfigIgnoringErrors(slug: slug)

            let loadedMenu = try await menuTask
            guard generation == loadGeneration, !Task.isCancelled else { return }

            menu = loadedMenu
            loadedLocale = locale
            feedbackConfig = await feedbackTask
            guard generation == loadGeneration, !Task.isCancelled else { return }
            state = loadedMenu.hasMenuItems ? .loaded : .empty
        } catch is CancellationError {
            return
        } catch let error as APIError where error == .cancelled {
            return
        } catch let error as APIError {
            guard generation == loadGeneration else { return }
            menu = nil
            loadedLocale = nil
            state = error == .notFound ? .notFound : .error(error.userFacingMessage)
        } catch {
            guard generation == loadGeneration else { return }
            menu = nil
            loadedLocale = nil
            state = .error(APIError.network.userFacingMessage)
        }
    }

    private func fetchFeedbackConfigIgnoringErrors(slug: String) async -> FeedbackConfig? {
        do {
            return try await api.fetchFeedbackConfig(slug: slug)
        } catch {
            return nil
        }
    }
}

extension RestaurantMenuViewModel.State: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.loaded, .loaded), (.empty, .empty), (.notFound, .notFound):
            true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            String(localized: lhsMessage) == String(localized: rhsMessage)
        default:
            false
        }
    }
}
