import Foundation
import Testing
import KlikMenuCore

// Serial execution isolates the handler shared by this suite's URLProtocol.
@Suite(.serialized)
struct HTTPClientTests {
    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [HTTPClientURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private func makeRequest() throws -> URLRequest {
        let url = try #require(URL(string: "https://http-client.test/menu?locale=pl"))
        return URLRequest(url: url)
    }

    @Test(arguments: [200, 204, 404, 500])
    func returnsHTTPResponseWithoutInterpretingStatus(statusCode: Int) async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            HTTPClientURLProtocol.setHandler(nil)
        }
        let request = try makeRequest()
        let body = statusCode == 204 ? Data() : Data("response body".utf8)
        let url = try #require(request.url)
        let response = try #require(HTTPURLResponse(
            url: url, statusCode: statusCode,
            httpVersion: "HTTP/1.1", headerFields: ["X-Test": "preserved"]
        ))
        HTTPClientURLProtocol.setHandler { _ in (response, body) }

        let (receivedData, receivedResponse) = try await URLSessionHTTPClient(session: session)
            .data(for: request)

        #expect(receivedData == body)
        #expect(receivedResponse.statusCode == statusCode)
        #expect(receivedResponse.url == request.url)
        #expect(receivedResponse.value(forHTTPHeaderField: "X-Test") == "preserved")
    }

    @Test func forwardsRequestMethodURLAndHeaders() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            HTTPClientURLProtocol.setHandler(nil)
        }
        var request = try makeRequest()
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let expectedURL = request.url
        HTTPClientURLProtocol.setHandler { received in
            #expect(received.url == expectedURL)
            #expect(received.httpMethod == "POST")
            #expect(received.value(forHTTPHeaderField: "Accept") == "application/json")
            let url = try #require(received.url)
            let response = try #require(HTTPURLResponse(
                url: url, statusCode: 200,
                httpVersion: nil, headerFields: nil
            ))
            return (response, Data())
        }

        _ = try await URLSessionHTTPClient(session: session).data(for: request)
    }

    @Test(arguments: [
        URLError.Code.timedOut, .notConnectedToInternet, .networkConnectionLost, .cannotFindHost
    ])
    func mapsTransportErrorsToNetwork(code: URLError.Code) async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            HTTPClientURLProtocol.setHandler(nil)
        }
        HTTPClientURLProtocol.setHandler { _ in throw URLError(code) }
        let request = try makeRequest()

        await #expect(throws: APIError.network) {
            try await URLSessionHTTPClient(session: session).data(for: request)
        }
    }

    @Test func rejectsNonHTTPResponse() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            HTTPClientURLProtocol.setHandler(nil)
        }
        let request = try makeRequest()
        let response = URLResponse(
            url: try #require(request.url), mimeType: "text/plain",
            expectedContentLength: 4, textEncodingName: "utf-8"
        )
        HTTPClientURLProtocol.setHandler { _ in (response, Data("body".utf8)) }

        await #expect(throws: APIError.network) {
            try await URLSessionHTTPClient(session: session).data(for: request)
        }
    }

    @Test func mapsURLCancellationToCancelled() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            HTTPClientURLProtocol.setHandler(nil)
        }
        HTTPClientURLProtocol.setHandler { _ in throw URLError(.cancelled) }
        let request = try makeRequest()

        await #expect(throws: APIError.cancelled) {
            try await URLSessionHTTPClient(session: session).data(for: request)
        }
    }

    @Test func mapsUnknownTransportErrorToNetwork() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            HTTPClientURLProtocol.setHandler(nil)
        }
        HTTPClientURLProtocol.setHandler { _ in throw NSError(domain: "HTTPClientTests", code: 42) }
        let request = try makeRequest()

        await #expect(throws: APIError.network) {
            try await URLSessionHTTPClient(session: session).data(for: request)
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func cancellingInFlightTaskReturnsCancelled() async throws {
        let session = makeSession()
        let (started, continuation) = AsyncStream<Void>.makeStream()
        defer {
            session.invalidateAndCancel()
            HTTPClientURLProtocol.setHandler(nil)
            continuation.finish()
        }
        HTTPClientURLProtocol.setHandler { _ in
            continuation.yield(())
            continuation.finish()
            return nil
        }
        let request = try makeRequest()
        let client = URLSessionHTTPClient(session: session)
        let task = Task { try await client.data(for: request) }
        defer { task.cancel() }

        // Cancel only after URLSession has started the intercepted request.
        for await _ in started { break }
        task.cancel()

        await #expect(throws: APIError.cancelled) {
            try await task.value
        }
    }
}
