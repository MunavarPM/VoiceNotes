//
//  PlayerViewModel.swift
//  VoiceNotes
//
//  Drives the expanded player screen. Mock playback for the scaffold.
//

import Foundation
import Observation

@Observable
final class PlayerViewModel {
    let recording: Recording
    var isPlaying = false
    var progress: Double = 0.35
    var waveformSamples: [Float]

    private let player: AudioPlayerService

    init(
        recording: Recording,
        player: AudioPlayerService = StubAudioPlayerService(),
        waveformService: WaveformService = StubWaveformService()
    ) {
        self.recording = recording
        self.player = player
        self.waveformSamples = waveformService.makeSamples(count: 60)
    }

    var elapsed: TimeInterval { recording.duration * progress }

    func togglePlay() {
        isPlaying.toggle()
    }

    func seek(to newProgress: Double) {
        progress = min(max(newProgress, 0), 1)
        player.seek(to: progress)
    }
}
