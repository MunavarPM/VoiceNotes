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
    /// Total duration of the loaded file, in seconds.
    private(set) var duration: TimeInterval = 0
    /// Playback speed (1x / 1.5x / 2x).
    private(set) var rate: Float = 1.0

    /// Elapsed time in seconds.
    var elapsed: TimeInterval { duration * progress }

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
            player.enableRate = true
            player.prepareToPlay()
            self.player = player
            currentFileName = fileName
            duration = player.duration
            player.play()
            player.rate = rate
            isPlaying = true
            startTicker()
        } catch {
            stop()
        }
    }

    func resume() {
        guard let player else { return }
        player.play()
        player.rate = rate
        isPlaying = true
        startTicker()
    }

    /// Play/pause the already-loaded file (no URL needed).
    func togglePlayPause() {
        guard player != nil else { return }
        isPlaying ? pause() : resume()
    }

    /// Jump forward (+) or back (−) by a number of seconds.
    func skip(by seconds: TimeInterval) {
        guard let player else { return }
        let target = min(max(player.currentTime + seconds, 0), player.duration)
        player.currentTime = target
        progress = player.duration > 0 ? target / player.duration : 0
    }

    /// Cycle 1x → 1.5x → 2x.
    func cycleRate() {
        let options: [Float] = [1.0, 1.5, 2.0]
        let index = options.firstIndex(of: rate) ?? 0
        rate = options[(index + 1) % options.count]
        player?.rate = rate
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
        duration = 0
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
                    self.duration = 0
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
