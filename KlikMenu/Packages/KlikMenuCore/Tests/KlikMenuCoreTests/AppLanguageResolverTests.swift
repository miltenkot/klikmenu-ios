import Foundation
import Testing
import KlikMenuCore

@Suite struct AppLanguageResolverTests {
    @Test(arguments: [
        ("en-US", SupportedLocale.en),
        ("de-DE", .de),
        ("uk-UA", .uk),
        ("cs-CZ", .cs),
        ("sk-SK", .sk),
        ("pl-PL", .pl),
        ("fr-FR", .pl),
        ("en", .en),
        ("de_AT", .de),
    ])
    func mapsPreferredLocalizations(input: String, expected: SupportedLocale) {
        #expect(AppLanguageResolver.resolve(languageCode: input) == expected)
        #expect(AppLanguageResolver(preferredLocalizations: [input]).resolve() == expected)
    }

    @Test func fallsBackThroughUnsupportedThenSupported() {
        let resolver = AppLanguageResolver(preferredLocalizations: ["fr-FR", "de-CH", "en"])
        #expect(resolver.resolve() == .de)
    }

    @Test func defaultsToPolishWhenEmpty() {
        #expect(AppLanguageResolver(preferredLocalizations: []).resolve() == .pl)
    }
}
