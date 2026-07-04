//
//  Color+Extension.swift
//  VoiceNotes
//
//  Hex initializer + the app's named brand colors.
//

import SwiftUI

extension Color {
    /// Create a color from a hex string. Supports "RGB", "RRGGBB" and
    /// "RRGGBBAA" (alpha last), with or without a leading '#'.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r, g, b, a: UInt64
        switch cleaned.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17, 255)
        case 6: // RRGGBB
            (r, g, b, a) = (value >> 16, value >> 8 & 0xFF, value & 0xFF, 255)
        case 8: // RRGGBBAA
            (r, g, b, a) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Brand colors (defined in Assets.xcassets/Colors)

    /// #367AF6 — accent / waveform.
    static let dodgerBlue = Color("367AF6")
    /// #06C809 — recording / "Done" (iOS) / success.
    static let limeGreen = Color("06C809")
    /// #767680 — solid gray (icons). Use `.opacity()` for translucent fills.
    static let darkGrayish = Color("7676801F")
    /// #96AAE1 — soft periwinkle for the recorder's water wave.
    static let waterWave = Color("96AAE1")
}
