import Foundation
import Testing
import KlikMenuCore

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
        "ftp://app.klikmenu.pl/menu/bistro-klik",
        "not-a-url"
    ])
    func rejectsInvalidURLs(_ urlString: String) {
        #expect(RestaurantMenuURLParser.parse(urlString) == nil)
    }
}
