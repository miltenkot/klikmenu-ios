import Testing
import KlikMenuCore

struct KlikMenuClipTests {
    @Test func sharedCoreModuleIsLinkedFromAppClip() {
        let route = RestaurantMenuURLParser.parse("https://app.klikmenu.pl/menu/bistro-klik")
        #expect(route?.slug == "bistro-klik")
    }
}
