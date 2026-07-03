//
//  PlayerViewModel.swift
//  VoiceNotes
//
//  Drives the expanded player. Reads/controls the SAME shared player as
//  the dashboard, so playback is consistent across the app.
//

import Foundation
import Observation

@Observable
final class PlayerViewModel {
    let recording: Recording

    private let player: AudioPlayerService
    private let fileManager: FileManagerService

    init(
        recording: Recording,
        player: AudioPlayerService,
        fileManager: FileManagerService = DefaultFileManagerService()
    ) {
        self.recording = recording
        self.player = player
        self.fileManager = fileManager
    }

    var isPlaying: Bool {
        player.currentFileName == recording.filePath && player.isPlaying
    }

    var progress: Double {
        player.currentFileName == recording.filePath ? player.progress : 0
    }

    var elapsed: TimeInterval {
        recording.duration * progress
    }

    var waveform: [Float] {
        recording.waveform
    }

    func togglePlay() {
        guard !recording.filePath.isEmpty else { return }
        let url = fileManager.url(forFileName: recording.filePath)
        player.toggle(url: url, fileName: recording.filePath)
    }

    func seek(to fraction: Double) {
        guard player.currentFileName == recording.filePath else { return }
        player.seek(to: fraction)
    }
}
