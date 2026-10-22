import Foundation
import Testing
@testable import KlikMenuCore

struct RestaurantMenuURLParserTests {

    @Test func acceptsValidMenuURL() {
        let route = RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/bistro-klik")
        #expect(route == RestaurantMenuRoute(slug: "bistro-klik"))
    }

    @Test func acceptsExplicitHTTPSPort443() {
        let route = RestaurantMenuURLParser.parse("https://app.klikmenu.pl:443/menu/bistro-klik")
        #expect(route?.slug == "bistro-klik")
    }

    @Test func ignoresQueryAndFragment() {
        let route = RestaurantMenuURLParser.parse(
            "https://app.klikmenu.pl/menu/bistro-klik?utm=1#section"
        )
        #expect(route?.slug == "bistro-klik")
    }

    @Test func acceptsPercentEncodedSlugWithoutForbiddenCharacters() {
        let route = RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/bistro%2Dklik")
        #expect(route?.slug == "bistro-klik")
    }

    @Test(arguments: [
        "http://app.klikmenu.pl/menu/bistro-klik",
        "https://www.app.klikmenu.pl/menu/bistro-klik",
        "https://klikmenu.pl/menu/bistro-klik",
        "https://api.klikmenu.pl/menu/bistro-klik",
        "https://app.klikmenu.pl.evil.com/menu/bistro-klik",
        "https://app.klikmenu.pl:8443/menu/bistro-klik",
        "https://app.klikmenu.pl/menus/bistro-klik",
        "https://app.klikmenu.pl/menu/",
        "https://app.klikmenu.pl/menu",
        "https://app.klikmenu.pl/menu/bistro-klik/extra",
        "https://app.klikmenu.pl/menu/bistro/klik",
        "https://app.klikmenu.pl/menu/bistro%2Fklik",
        "https://app.klikmenu.pl/menu/bistro%5Cklik",
        "https://app.klikmenu.pl/menu/bistro%20klik",
        "https://app.klikmenu.pl/menu/%20",
        "https://app.klikmenu.pl/menu/Bistro-Klik",
        "https://app.klikmenu.pl/menu/-bistro",
        "https://app.klikmenu.pl/menu/bistro-",
        "https://app.klikmenu.pl/menu/bistro--klik",
        "ftp://app.klikmenu.pl/menu/bistro-klik",
        "not-a-url"
    ])
    func rejectsInvalidURLs(_ urlString: String) {
        #expect(RestaurantMenuURLParser.parse(urlString) == nil)
    }

    @Test func rejectsMissingSlug() {
        #expect(RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/") == nil)
        #expect(RestaurantMenuInvocation.route(from: "") == nil)
        #expect(RestaurantMenuInvocation.route(from: "   ") == nil)
    }

    @Test func invocationAcceptsBareSlug() {
        let route = RestaurantMenuInvocation.route(from: "bistro-klik")
        #expect(route == RestaurantMenuRoute(slug: "bistro-klik"))
    }

    @Test func invocationRejectsForeignURL() {
        let route = RestaurantMenuInvocation.route(from: "https://example.com/menu/bistro-klik")
        #expect(route == nil)
    }

    @Test func acceptsLocalDevelopmentHTTPWhenAllowed() {
        let url = "http://192.168.100.18:5173/menu/pubmentzen"
        let route = RestaurantMenuURLParser.parse(
            URLComponents(string: url)!,
            allowsLocalDevelopmentHTTP: true
        )
        #expect(route == RestaurantMenuRoute(slug: "pubmentzen"))
    }

    @Test func rejectsLocalDevelopmentHTTPWhenNotAllowed() {
        let url = "http://192.168.100.18:5173/menu/pubmentzen"
        let route = RestaurantMenuURLParser.parse(
            URLComponents(string: url)!,
            allowsLocalDevelopmentHTTP: false
        )
        #expect(route == nil)
    }

    @Test func acceptsProductionHTTPSWhenLocalHTTPDisabled() {
        let route = RestaurantMenuURLParser.parse(
            URLComponents(string: "https://app.klikmenu.pl/menu/pubmentzen")!,
            allowsLocalDevelopmentHTTP: false
        )
        #expect(route == RestaurantMenuRoute(slug: "pubmentzen"))
    }

    @Test func rejectsPublicHTTPEvenWhenLocalHTTPAllowed() {
        let route = RestaurantMenuURLParser.parse(
            URLComponents(string: "http://app.klikmenu.pl/menu/pubmentzen")!,
            allowsLocalDevelopmentHTTP: true
        )
        #expect(route == nil)
    }

    @Test func acceptsLocalhostDevelopmentHTTPWhenAllowed() {
        let route = RestaurantMenuURLParser.parse(
            URLComponents(string: "http://localhost:5173/menu/pubmentzen")!,
            allowsLocalDevelopmentHTTP: true
        )
        #expect(route == RestaurantMenuRoute(slug: "pubmentzen"))
    }
}
