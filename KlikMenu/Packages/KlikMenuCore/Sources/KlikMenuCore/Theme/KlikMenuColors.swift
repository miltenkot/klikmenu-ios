import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension Color {
    public static let klikPageBackground = Color(
        light: Color(red: 246 / 255, green: 242 / 255, blue: 233 / 255),
        dark: Color(red: 16 / 255, green: 25 / 255, blue: 21 / 255)
    )
    public static let klikSurface = Color(
        light: Color(red: 1, green: 253 / 255, blue: 248 / 255),
        dark: Color(red: 24 / 255, green: 36 / 255, blue: 31 / 255)
    )
    public static let klikText = Color(
        light: Color(red: 37 / 255, green: 36 / 255, blue: 31 / 255),
        dark: Color(red: 244 / 255, green: 238 / 255, blue: 227 / 255)
    )
    public static let klikMuted = Color(
        light: Color(red: 108 / 255, green: 105 / 255, blue: 96 / 255),
        dark: Color(red: 189 / 255, green: 181 / 255, blue: 168 / 255)
    )
    public static let klikBrand = Color(
        light: Color(red: 23 / 255, green: 61 / 255, blue: 50 / 255),
        dark: Color(red: 40 / 255, green: 99 / 255, blue: 79 / 255)
    )
    public static let klikHero = Color(
        light: Color(red: 23 / 255, green: 61 / 255, blue: 50 / 255),
        dark: Color(red: 16 / 255, green: 47 / 255, blue: 39 / 255)
    )
    public static let klikAccent = Color(
        light: Color(red: 215 / 255, green: 82 / 255, blue: 42 / 255),
        dark: Color(red: 237 / 255, green: 116 / 255, blue: 76 / 255)
    )
    public static let klikBorder = Color(
        light: Color(red: 225 / 255, green: 217 / 255, blue: 202 / 255),
        dark: Color(red: 57 / 255, green: 73 / 255, blue: 64 / 255)
    )
    public static let klikHeroText = Color(red: 1, green: 253 / 255, blue: 248 / 255)
    public static let klikHeroMuted = Color(
        light: Color(red: 218 / 255, green: 229 / 255, blue: 223 / 255),
        dark: Color(red: 196 / 255, green: 216 / 255, blue: 207 / 255)
    )
    public static let klikDietaryBackground = Color(
        light: Color(red: 237 / 255, green: 247 / 255, blue: 241 / 255),
        dark: Color(red: 25 / 255, green: 58 / 255, blue: 44 / 255)
    )
    public static let klikDietaryBorder = Color(
        light: Color(red: 185 / 255, green: 213 / 255, blue: 198 / 255),
        dark: Color(red: 55 / 255, green: 110 / 255, blue: 85 / 255)
    )
    public static let klikDietaryText = Color(
        light: Color(red: 23 / 255, green: 92 / 255, blue: 71 / 255),
        dark: Color(red: 145 / 255, green: 226 / 255, blue: 184 / 255)
    )
}

extension Color {
    fileprivate init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(
            uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            }
        )
        #elseif canImport(AppKit)
        self.init(
            nsColor: NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(dark)
                    : NSColor(light)
            }
        )
        #else
        self = light
        #endif
    }
}

#if canImport(AppKit) && !canImport(UIKit)
import AppKit
#endif
