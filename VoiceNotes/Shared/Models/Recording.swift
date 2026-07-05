//
//  Recording.swift
//  VoiceNotes
//
//  SwiftData model for a real, persisted voice recording.
//

import Foundation
import SwiftData

@Model
final class Recording {
    @Attribute(.unique) var id: UUID
    var title: String
    /// File NAME (e.g. "UUID.m4a") inside the Recordings directory.
    /// We store the name — not an absolute path — because a sandboxed
    /// app's container path can change between launches.
    var filePath: String
    /// Duration in seconds.
    var duration: TimeInterval
    var createdAt: Date
    var isStarred: Bool
    var isShared: Bool
    /// Normalized 0...1 waveform bars captured while recording, for playback UI.
    var waveform: [Float]
    /// Speech-to-text transcript (nil until the user transcribes it).
    var transcript: String?

    init(
        id: UUID = UUID(),
        title: String,
        filePath: String,
        duration: TimeInterval,
        createdAt: Date = Date(),
        isStarred: Bool = false,
        isShared: Bool = false,
        waveform: [Float] = [],
        transcript: String? = nil
    ) {
        self.id = id
        self.title = title
        self.filePath = filePath
        self.duration = duration
        self.createdAt = createdAt
        self.isStarred = isStarred
        self.isShared = isShared
        self.waveform = waveform
        self.transcript = transcript
    }
}
