import Testing
import KlikMenuCore

struct KlikMenuTests {
    @Test func sharedCoreModuleIsLinked() {
        let route = RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/bistro-klik")
        #expect(route?.slug == "bistro-klik")
        #expect(PriceFormatter.string(price: "24.00", currency: "PLN").contains("24"))
    }
}
