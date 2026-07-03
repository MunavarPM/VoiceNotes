//
//  Color+Theme.swift
//  VoiceNotes
//
//  Cross-platform brand colors used across iOS and macOS.
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

    /// Subtle fill used for search field, chips, and the recorder pill.
    static let fieldFill = Color.gray.opacity(0.12)

    /// Periwinkle blue used for the live waveform (from the mockups).
    static let waveform = Color(red: 0.45, green: 0.55, blue: 0.85)

    /// Light green "Done" pill background (iOS mockup).
    static let doneGreen = Color(red: 0.85, green: 0.94, blue: 0.84)
    static let doneGreenText = Color(red: 0.15, green: 0.55, blue: 0.30)
}
