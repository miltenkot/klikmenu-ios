import Foundation
import Observation

@MainActor
@Observable
public final class RestaurantMenuViewModel {
    public enum State: Equatable, Sendable {
        case loading
        case loaded
        case empty
        case notFound
        case error(String)
    }

    public private(set) var state: State = .loading
    public private(set) var menu: RestaurantMenu?
    public private(set) var feedbackConfig: FeedbackConfig?

    private let api: any KlikMenuAPIClient
    private var slug = ""
    private var loadTask: Task<Void, Never>?

    public init(api: any KlikMenuAPIClient) {
        self.api = api
    }

    public var showFeedbackButton: Bool {
        feedbackConfig?.isFeedbackAvailable == true
    }

    public func load(slug: String) async {
        loadTask?.cancel()
        self.slug = slug
        state = .loading
        menu = nil

        let task = Task { await performLoad(slug: slug) }
        loadTask = task
        await task.value
    }

    public func retry() async {
        await load(slug: slug)
    }

    public func makeFeedbackViewModel() -> FeedbackViewModel {
        FeedbackViewModel(api: api)
    }

    private func performLoad(slug: String) async {
        do {
            async let menuTask = api.fetchMenu(slug: slug)
            async let feedbackTask = fetchFeedbackConfigIgnoringErrors(slug: slug)

            let loadedMenu = try await menuTask
            if Task.isCancelled { return }

            menu = loadedMenu
            feedbackConfig = await feedbackTask
            state = loadedMenu.hasMenuItems ? .loaded : .empty
        } catch is CancellationError {
            return
        } catch let error as APIError where error == .cancelled {
            return
        } catch let error as APIError {
            menu = nil
            state = error == .notFound ? .notFound : .error(error.userFacingMessage)
        } catch {
            menu = nil
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
