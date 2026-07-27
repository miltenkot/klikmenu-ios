import Foundation

public struct FeedbackConfig: Sendable, Equatable {
    public let enabled: Bool
    public let restaurantName: String
    public let waiters: [PublicWaiter]

    public init(enabled: Bool, restaurantName: String, waiters: [PublicWaiter]) {
        self.enabled = enabled
        self.restaurantName = restaurantName
        self.waiters = waiters
    }

    public var isFeedbackAvailable: Bool {
        enabled && !waiters.isEmpty
    }
}

public struct PublicWaiter: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let photoURL: URL?

    public init(id: String, name: String, photoURL: URL?) {
        self.id = id
        self.name = name
        self.photoURL = photoURL
    }

    public var initial: String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased()
    }
}

public struct FeedbackRequest: Sendable, Equatable {
    public let waiterID: String
    public let rating: Int
    public let comment: String?

    public init(waiterID: String, rating: Int, comment: String?) {
        self.waiterID = waiterID
        self.rating = rating
        self.comment = comment
    }
}
