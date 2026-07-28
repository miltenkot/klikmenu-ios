import Foundation

public protocol KlikMenuAPIClient: Sendable {
    func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu
    func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig
    func submitFeedback(slug: String, request: FeedbackRequest) async throws -> SubmitFeedbackResponseDTO
}

public struct LiveKlikMenuAPIClient: KlikMenuAPIClient, Sendable {
    public static let defaultBaseURL: URL = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.klikmenu.pl"
        return components.url ?? URL(fileURLWithPath: "/api-klikmenu-pl-missing")
    }()

    public let baseURL: URL
    private let http: any HTTPClient
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(
        baseURL: URL = LiveKlikMenuAPIClient.defaultBaseURL,
        http: any HTTPClient = URLSessionHTTPClient(timeout: 20)
    ) {
        self.baseURL = baseURL
        self.http = http
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    public func fetchMenu(slug: String, locale: SupportedLocale) async throws -> RestaurantMenu {
        let response: PublicMenuResponseDTO = try await get(
            pathComponents: ["api", "v1", "public", "restaurants", slug, "menu"],
            queryItems: [URLQueryItem(name: "locale", value: locale.rawValue)]
        )
        return response.data.asDomain()
    }

    public func fetchFeedbackConfig(slug: String) async throws -> FeedbackConfig {
        let response: FeedbackConfigResponseDTO = try await get(
            pathComponents: ["api", "v1", "public", "restaurants", slug, "feedback-config"]
        )
        return response.data.asDomain()
    }

    public func submitFeedback(
        slug: String,
        request: FeedbackRequest
    ) async throws -> SubmitFeedbackResponseDTO {
        var urlRequest = try makeRequest(
            pathComponents: ["api", "v1", "public", "restaurants", slug, "feedback"]
        )
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try encoder.encode(
            SubmitFeedbackRequestDTO(
                waiterId: request.waiterID,
                rating: request.rating,
                comment: request.comment
            )
        )
        return try await perform(urlRequest)
    }

    private func get<T: Decodable & Sendable>(
        pathComponents: [String],
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        try await perform(makeRequest(pathComponents: pathComponents, queryItems: queryItems))
    }

    private func makeRequest(
        pathComponents: [String],
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.network
        }

        let encodedPath = pathComponents
            .map { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? $0 }
            .joined(separator: "/")
        components.percentEncodedPath = "/" + encodedPath
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw APIError.network
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func perform<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await http.data(for: request)
        guard (200...299).contains(response.statusCode) else {
            if response.statusCode == 404 {
                throw APIError.notFound
            }
            let dto = try? decoder.decode(APIErrorDTO.self, from: data)
            throw APIError.http(
                statusCode: response.statusCode,
                message: dto?.error.message ?? "Wystąpił błąd serwera.",
                code: dto?.error.code
            )
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }
}
