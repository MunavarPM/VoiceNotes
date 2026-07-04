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

    /// Translucent gray fill for the search field, chips, and progress tracks.
    static let fieldFill = Color.darkGrayish

    /// Waveform bars (Dodger Blue).
    static let waveform = Color.dodgerBlue
}
