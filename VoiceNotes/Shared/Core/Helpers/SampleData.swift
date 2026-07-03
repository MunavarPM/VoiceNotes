//
//  SampleData.swift
//  VoiceNotes
//
//  PREVIEW-ONLY sample recordings. The running app never uses these — it
//  starts empty and persists real recordings via SwiftData. These exist
//  purely so SwiftUI #Preview blocks can render populated UI.
//

import Foundation

extension Recording {
    /// A synthetic waveform for previews.
    static var previewWaveform: [Float] {
        (0..<50).map { Float(abs(sin(Double($0) * 0.4)) * 0.8 + 0.15) }
    }

    static var samples: [Recording] {
        [
            Recording(
                title: "Momentum in FIFA and Startup Strategy",
                filePath: "",
                duration: 83,
                createdAt: Date().addingTimeInterval(-3600),
                isStarred: true,
                waveform: previewWaveform
            ),
            Recording(
                title: "Morning Sync on Video Messages to Prod and Express Payouts",
                filePath: "",
                duration: 1649,
                createdAt: Date().addingTimeInterval(-90_000),
                isShared: true,
                waveform: previewWaveform
            )
        ]
    }
}
