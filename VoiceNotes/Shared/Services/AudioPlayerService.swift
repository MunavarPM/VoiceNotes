//
//  AudioPlayerService.swift
//  VoiceNotes
//
//  Real AVAudioPlayer-backed playback. This is an @Observable *shared*
//  service: it is the single source of truth for what's playing, so only
//  one recording plays at a time and every view (list rows + expanded
//  player) stays in sync. Works on iOS and macOS.
//

import Foundation
import AVFoundation

@Observable
final class AudioPlayerService {
    /// File name of the recording currently loaded, or nil.
    private(set) var currentFileName: String?
    private(set) var isPlaying = false
    /// Playback position as a 0...1 fraction.
    private(set) var progress: Double = 0

    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var ticker: Task<Void, Never>?

    func toggle(url: URL, fileName: String) {
        if currentFileName == fileName {
            isPlaying ? pause() : resume()
        } else {
            play(url: url, fileName: fileName)
        }
    }

    func play(url: URL, fileName: String) {
        stop()
        do {
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)
            #endif
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            self.player = player
            currentFileName = fileName
            player.play()
            isPlaying = true
            startTicker()
        } catch {
            stop()
        }
    }

    func resume() {
        guard let player else { return }
        player.play()
        isPlaying = true
        startTicker()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopTicker()
    }

    func seek(to fraction: Double) {
        guard let player else { return }
        let clamped = max(0, min(1, fraction))
        player.currentTime = clamped * player.duration
        progress = clamped
    }

    func stop() {
        stopTicker()
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        currentFileName = nil
    }

    // MARK: - Progress ticker (MainActor-isolated async loop)

    private func startTicker() {
        stopTicker()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000) // ~33 fps
                guard let self, let player = self.player else { return }
                if player.duration > 0 {
                    self.progress = player.currentTime / player.duration
                }
                // Detect natural end of playback.
                if !player.isPlaying && self.isPlaying {
                    self.isPlaying = false
                    self.progress = 0
                    self.currentFileName = nil
                    self.stopTicker()
                    return
                }
            }
        }
    }

    private func stopTicker() {
        ticker?.cancel()
        ticker = nil
    }
}
