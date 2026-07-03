//
//  AudioRecorderService.swift
//  VoiceNotes
//
//  Real AVAudioRecorder-backed recording with microphone permission and
//  live metering. Cross-platform: AVAudioSession is configured on iOS only
//  (macOS has no audio session), and permission uses the platform API.
//

import Foundation
import AVFoundation

protocol AudioRecorderService: AnyObject {
    var isRecording: Bool { get }
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
}
