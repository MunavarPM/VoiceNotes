//
//  Haptics.swift
//  VoiceNotes
//
//  One reusable, cross-platform haptics helper. Call the semantic methods
//  from any view (`Haptics.tap()`, `Haptics.success()`, …). On iOS these use
//  UIKit feedback generators; on macOS they map to the trackpad haptic
//  performer; anywhere else they safely no-op.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum Haptics {
    /// Light tap — toggles, selections, small taps (star, share).
    static func tap() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }

    /// Firmer impact — meaningful actions like starting a recording.
    static func impact() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
        #endif
    }

    /// Success — a recording saved / shared successfully.
    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }

    /// Warning — destructive actions like delete.
    static func warning() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }
}
