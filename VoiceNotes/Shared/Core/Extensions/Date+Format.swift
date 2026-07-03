//
//  Date+Format.swift
//  VoiceNotes
//
//  Formatting helpers for recording captions and durations.
//

import Foundation

extension Date {
    /// e.g. "Sep 13 · 12:30 PM"
    var recordingCaption: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d · h:mm a"
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    /// e.g. 1649 -> "27:29"
    var durationString: String {
        let total = Int(self.rounded())
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
