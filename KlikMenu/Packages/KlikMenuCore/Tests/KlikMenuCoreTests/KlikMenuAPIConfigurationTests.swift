import Foundation
import Testing
@testable import KlikMenuCore

@Test func productionAPIBaseURLIsConfigured() {
    #expect(KlikMenuAPIConfiguration.productionBaseURL.absoluteString == "https://api.klikmenu.pl")
}

@Test func developmentAPIBaseURLIsConfigured() {
    #expect(KlikMenuAPIConfiguration.developmentBaseURL.absoluteString == "http://192.168.100.18:3000")
}

@Test func liveAPIClientUsesConfiguredBaseURL() {
    #expect(LiveKlikMenuAPIClient.defaultBaseURL == KlikMenuAPIConfiguration.baseURL)
}
