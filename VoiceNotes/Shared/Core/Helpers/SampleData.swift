//
//  SampleData.swift
//  VoiceNotes
//
//  Sample recordings used for SwiftUI previews and the mock repository
//  while the app is a UI scaffold (no real audio yet).
//

import Foundation

extension Recording {
    static var samples: [Recording] {
        [
            Recording(
                title: "Momentum in FIFA and Startup Strategy",
                duration: 83,             // 01:23
                createdAt: Date().addingTimeInterval(-3600),
                isStarred: true
            ),
            Recording(
                title: "Morning Sync on Video Messages to Prod and Express Payouts",
                duration: 1649,           // 27:29
                createdAt: Date().addingTimeInterval(-90_000),
                isShared: true
            ),
            Recording(
                title: "Design Review — Waveform and Player Polish",
                duration: 512,            // 08:32
                createdAt: Date().addingTimeInterval(-172_800),
                isStarred: true,
                isShared: true
            )
        ]
    }
}
