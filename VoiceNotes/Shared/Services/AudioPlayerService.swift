//
//  AudioPlayerService.swift
//  VoiceNotes
//
//  Owns AVAudioPlayer, play/pause/seek and playback progress.
//  Stub for the UI scaffold.
//

import Foundation

protocol AudioPlayerService: AnyObject {
    var isPlaying: Bool { get }
    var progress: Double { get }
    func play(url: URL)
    func pause()
    func seek(to progress: Double)
}

final class StubAudioPlayerService: AudioPlayerService {
    private(set) var isPlaying = false
    private(set) var progress: Double = 0

    func play(url: URL) { isPlaying = true }
    func pause() { isPlaying = false }
    func seek(to progress: Double) { self.progress = min(max(progress, 0), 1) }
}
