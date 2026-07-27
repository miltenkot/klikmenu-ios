import Testing
import KlikMenuCore

@Test func mapsUserFacingErrors() {
    #expect(
        String(localized: APIError.notFound.userFacingMessage) == "Nie znaleziono restauracji."
    )
    #expect(
        String(localized: APIError.http(statusCode: 429, message: "x", code: nil).userFacingMessage)
            .localizedCaseInsensitiveContains("zbyt wiele")
    )
    #expect(
        String(localized: APIError.http(statusCode: 500, message: "", code: nil).userFacingMessage)
            .localizedCaseInsensitiveContains("serwer")
    )
}
