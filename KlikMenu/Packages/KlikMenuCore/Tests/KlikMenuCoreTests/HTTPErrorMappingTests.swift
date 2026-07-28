import Testing
import KlikMenuCore
import Foundation

private let polish = Locale(identifier: "pl")
private let english = Locale(identifier: "en")

private func localized(_ resource: LocalizedStringResource, locale: Locale) -> String {
    var copy = resource
    copy.locale = locale
    return String(localized: copy)
}

@Test func mapsUserFacingErrors() {
    #expect(
        localized(APIError.notFound.userFacingMessage, locale: polish)
            == "Nie znaleziono restauracji."
    )
    #expect(
        localized(APIError.notFound.userFacingMessage, locale: english)
            == "Restaurant not found."
    )
    #expect(
        localized(
            APIError.http(statusCode: 429, message: "x", code: nil).userFacingMessage,
            locale: polish
        )
        .localizedCaseInsensitiveContains("zbyt wiele")
    )
    #expect(
        localized(
            APIError.http(statusCode: 429, message: "x", code: nil).userFacingMessage,
            locale: english
        )
        .localizedCaseInsensitiveContains("too many")
    )
    #expect(
        localized(
            APIError.http(statusCode: 500, message: "", code: nil).userFacingMessage,
            locale: polish
        )
        .localizedCaseInsensitiveContains("serwer")
    )
    #expect(
        localized(
            APIError.http(statusCode: 500, message: "", code: nil).userFacingMessage,
            locale: english
        )
        .localizedCaseInsensitiveContains("server")
    )
}
