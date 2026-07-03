//
//  AppConstants.swift
//  VoiceNotes
//
//  Centralized strings, sizes, and layout constants.
//

import SwiftUI

enum AppConstants {
    static let appName = "Voice Notes"
    static let askAI = "Ask AI"
    static let doneTitle = "Done"
    static let searchPlaceholder = "Search"

    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let cardSpacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let waveformBarCount = 40
    }
}
