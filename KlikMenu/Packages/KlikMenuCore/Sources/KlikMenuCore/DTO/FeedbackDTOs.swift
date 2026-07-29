import Foundation

public struct FeedbackConfigResponseDTO: Decodable, Sendable {
    public let data: FeedbackConfigDTO
}

public struct FeedbackConfigDTO: Decodable, Sendable {
    public let enabled: Bool
    public let restaurantName: String
    public let baseLocale: String
    public let availableLocales: [String]
    public let waiters: [PublicWaiterDTO]

    private enum CodingKeys: String, CodingKey {
        case enabled, restaurantName, baseLocale, availableLocales, waiters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decode(Bool.self, forKey: .enabled)
        restaurantName = try container.decode(String.self, forKey: .restaurantName)
        baseLocale = try container.decodeIfPresent(String.self, forKey: .baseLocale) ?? SupportedLocale.default.rawValue
        availableLocales = try container.decodeIfPresent([String].self, forKey: .availableLocales) ?? []
        waiters = try container.decodeIfPresent([PublicWaiterDTO].self, forKey: .waiters) ?? []
    }
}

public struct PublicWaiterDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let photoUrl: String?
}

public struct SubmitFeedbackRequestDTO: Encodable, Sendable {
    public let waiterId: String
    public let rating: Int
    public let comment: String?
    public let website: String

    public init(waiterId: String, rating: Int, comment: String?, website: String = "") {
        self.waiterId = waiterId
        self.rating = rating
        self.comment = comment
        self.website = website
    }
}

public struct SubmitFeedbackResponseDTO: Decodable, Sendable {
    public let accepted: Bool?

    public init(accepted: Bool?) {
        self.accepted = accepted
    }
}

public struct APIErrorDTO: Decodable, Sendable {
    public let error: Detail

    public struct Detail: Decodable, Sendable {
        public let code: String
        public let message: String

        private enum CodingKeys: String, CodingKey {
            case code, message, details
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            code = try container.decode(String.self, forKey: .code)
            message = try container.decode(String.self, forKey: .message)
            _ = try? container.decodeNil(forKey: .details)
        }
    }
}
