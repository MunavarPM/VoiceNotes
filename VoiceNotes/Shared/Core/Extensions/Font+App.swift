//
//  Font+App.swift
//  VoiceNotes
//
//  App typography. SF Pro is the Apple system font (built-in, no file needed);
//  Inter is a bundled custom font used for the "Ask AI" accent. Views use the
//  semantic styles below rather than hard-coding sizes/weights, so type stays
//  consistent and easy to change in one place.
//

import SwiftUI

extension Font {

    // MARK: - Base builders

    /// SF Pro at an explicit size + weight (SF Pro IS the system font).
    static func sfPro(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    /// Inter at an explicit size + weight. Falls back to the system font
    /// until the Inter files are bundled (see FontRegistrar).
    static func inter(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom(InterFont.name(for: weight), size: size)
    }

    // MARK: - Semantic styles (SF Pro)

    static let appLargeTitle  = Font.sfPro(32, .bold)      // "Voice Notes" (iOS)
    static let recordingTitle = Font.sfPro(17, .semibold)  // recording name
    static let rowCaption     = Font.sfPro(12, .regular)   // date / duration
    static let controlLabel   = Font.sfPro(15, .medium)
    static let smallLabel     = Font.sfPro(13, .regular)

    // MARK: - Accent (Inter)

    static let askAI = Font.inter(15, .semibold)
}

/// Inter font metadata. Note the filenames (with `_18pt`) differ from the
/// PostScript names (no underscore) — registration needs the filenames,
/// `Font.custom` needs the PostScript names.
enum InterFont {
    /// Resource filenames (without extension) to register from the bundle.
    static let fileNames = [
        "Inter_18pt-Regular",
        "Inter_18pt-Medium",
        "Inter_18pt-SemiBold",
        "Inter_18pt-Bold"
    ]

    /// PostScript name for a weight — what `Font.custom(_:size:)` needs.
    static func name(for weight: Font.Weight) -> String {
        switch weight {
        case .bold:     "Inter18pt-Bold"
        case .semibold: "Inter18pt-SemiBold"
        case .medium:   "Inter18pt-Medium"
        default:        "Inter18pt-Regular"
        }
    }
}
