//
//  Color+Theme.swift
//  VoiceNotes
//
//  Semantic colors mapped onto the brand palette (see Color+Extension).
//

import SwiftUI

extension Color {
    /// Primary window/screen background, adaptive per platform.
    static var appBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .textBackgroundColor)
        #endif
    }

    /// Translucent gray fill for the search field, chips, and player capsules
    /// (the solid brand gray at ~12%, matching #7676801F).
    static let fieldFill = Color.darkGrayish.opacity(0.12)

    /// Waveform bars (Dodger Blue).
    static let waveform = Color.dodgerBlue
}
