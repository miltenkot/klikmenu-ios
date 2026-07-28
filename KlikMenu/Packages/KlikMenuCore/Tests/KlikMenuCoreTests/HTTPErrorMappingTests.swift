import Foundation
import Testing
import KlikMenuCore

@Test func mapsUserFacingErrors() {
    #expect(String(localized: APIError.notFound.userFacingMessage).isEmpty == false)
    #expect(
        String(localized: APIError.http(statusCode: 429, message: "x", code: nil).userFacingMessage)
            .isEmpty == false
    )
    #expect(
        String(localized: APIError.http(statusCode: 500, message: "", code: nil).userFacingMessage)
            .isEmpty == false
    )
    #expect(String(localized: APIError.decoding.userFacingMessage).isEmpty == false)
}
