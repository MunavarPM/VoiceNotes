//
//  AudioRecorderService.swift
//  VoiceNotes
//
//  Real AVAudioRecorder-backed recording with microphone permission and
//  live metering. Cross-platform: AVAudioSession is configured on iOS only
//  (macOS has no audio session), and permission uses the platform API.
//
//  Supports background recording (see UIBackgroundModes = audio) and handles
//  audio-session interruptions (phone calls, Siri) by pausing and resuming.
//

import Foundation
import AVFoundation

/// An audio-session interruption event (iOS).
enum AudioInterruption {
    case began
    case ended(shouldResume: Bool)
}

protocol AudioRecorderService: AnyObject {
    var isRecording: Bool { get }
    /// Called on the main queue when the audio session is interrupted/resumed.
    var onInterruption: ((AudioInterruption) -> Void)? { get set }
    /// Requests microphone access. Returns true if granted.
    func requestPermission() async -> Bool
    /// Begins recording to `url`. Throws if the recorder can't start.
    func start(url: URL) throws
    /// Stops recording and returns the recorded duration in seconds.
    func stop() -> TimeInterval
    /// Normalized 0...1 microphone power for the live waveform.
    func currentPower() -> Float
}

final class DefaultAudioRecorderService: AudioRecorderService {
    private var recorder: AVAudioRecorder?
    private(set) var isRecording = false
    var onInterruption: ((AudioInterruption) -> Void)?

    private var interruptionObserver: NSObjectProtocol?

    func requestPermission() async -> Bool {
        #if os(iOS)
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        #else
        return await AVCaptureDevice.requestAccess(for: .audio)
        #endif
    }

    func start(url: URL) throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)
        observeInterruptions()
        #endif

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.record()
        self.recorder = recorder
        isRecording = true
    }

    func stop() -> TimeInterval {
        let duration = recorder?.currentTime ?? 0
        recorder?.stop()
        recorder = nil
        isRecording = false
        removeInterruptionObserver()
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif
        return duration
    }

    func currentPower() -> Float {
        guard let recorder else { return 0 }
        recorder.updateMeters()
        let decibels = recorder.averagePower(forChannel: 0)   // ~ -160...0 dB
        let floorDb: Float = -55
        guard decibels > floorDb else { return 0.05 }
        let normalized = (decibels - floorDb) / (0 - floorDb) // 0...1
        return max(0.05, min(1, normalized))
    }

    // MARK: - Interruptions (iOS)

    private func observeInterruptions() {
        #if os(iOS)
        removeInterruptionObserver()
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleInterruption(notification)
        }
        #endif
    }

    private func removeInterruptionObserver() {
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
            self.interruptionObserver = nil
        }
    }

    #if os(iOS)
    private func handleInterruption(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let rawType = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: rawType)
        else { return }

        switch type {
        case .began:
            // The system has already paused the recorder.
            onInterruption?(.began)

        case .ended:
            let rawOptions = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let shouldResume = AVAudioSession.InterruptionOptions(rawValue: rawOptions).contains(.shouldResume)
            if shouldResume {
                try? AVAudioSession.sharedInstance().setActive(true)
                recorder?.record()   // continue appending to the same file
            }
            onInterruption?(.ended(shouldResume: shouldResume))

        @unknown default:
            break
        }
    }
    #endif
}
