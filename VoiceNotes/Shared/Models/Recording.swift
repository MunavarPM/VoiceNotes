//
//  Recording.swift
//  VoiceNotes
//
//  SwiftData model representing a single voice recording.
//

import Foundation
import SwiftData

@Model
final class Recording {
    @Attribute(.unique) var id: UUID
    var title: String
    /// Relative path/name of the .m4a file in the Documents directory.
    var filePath: String
    /// Duration in seconds.
    var duration: TimeInterval
    var createdAt: Date
    var isStarred: Bool
    var isShared: Bool

    init(
        id: UUID = UUID(),
        title: String,
        filePath: String = "",
        duration: TimeInterval,
        createdAt: Date = Date(),
        isStarred: Bool = false,
        isShared: Bool = false
    ) {
        self.id = id
        self.title = title
        self.filePath = filePath
        self.duration = duration
        self.createdAt = createdAt
        self.isStarred = isStarred
        self.isShared = isShared
    }
}
