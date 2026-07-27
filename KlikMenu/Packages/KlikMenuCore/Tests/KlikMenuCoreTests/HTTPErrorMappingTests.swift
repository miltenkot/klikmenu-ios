import Testing
import KlikMenuCore

@Test func mapsUserFacingErrors() {
    #expect(APIError.notFound.userFacingMessage == "Nie znaleziono restauracji.")
    #expect(
        APIError.http(statusCode: 429, message: "x", code: nil)
            .userFacingMessage
            .localizedCaseInsensitiveContains("zbyt wiele")
    )
    #expect(
        APIError.http(statusCode: 500, message: "", code: nil)
            .userFacingMessage
            .localizedCaseInsensitiveContains("serwer")
    )
}
