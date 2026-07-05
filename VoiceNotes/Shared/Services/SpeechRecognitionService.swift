//
//  SpeechRecognitionService.swift
//  VoiceNotes
//
//  Live speech-to-text using Apple's Speech framework + AVAudioEngine.
//  Streams partial transcriptions and a mic level (for the wave) as you
//  speak. Works on iOS and macOS. On-device recognition is used when the
//  device supports it (no network needed).
//

import Foundation
import Speech
import AVFoundation

protocol SpeechRecognitionService: AnyObject {
    /// Requests speech-recognition + microphone permission.
    func requestPermission() async -> Bool
    /// Starts listening. `onText` fires with the running transcription,
    /// `onLevel` with a 0...1 mic level, `onStop` when it ends on its own.
    func start(
        onText: @escaping (String) -> Void,
        onLevel: @escaping (Float) -> Void,
        onStop: @escaping () -> Void
    ) throws
    func stop()
    /// Transcribes an existing audio file to text (nil on failure).
    func transcribe(url: URL) async -> String?
}

enum SpeechError: Error { case unavailable }

final class DefaultSpeechRecognitionService: SpeechRecognitionService {
    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestPermission() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        guard speechAuthorized else { return false }

        #if os(iOS)
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { continuation.resume(returning: $0) }
        }
        #else
        return await AVCaptureDevice.requestAccess(for: .audio)
        #endif
    }

    func start(
        onText: @escaping (String) -> Void,
        onLevel: @escaping (Float) -> Void,
        onStop: @escaping () -> Void
    ) throws {
        stop()

        guard let recognizer, recognizer.isAvailable else { throw SpeechError.unavailable }

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        #endif

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
            let level = Self.rms(of: buffer)
            DispatchQueue.main.async { onLevel(level) }
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async { onText(text) }
            }
            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async { onStop() }
            }
        }
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        request = nil
        task?.cancel()
        task = nil

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    func transcribe(url: URL) async -> String? {
        guard let recognizer, recognizer.isAvailable else { return nil }
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        return await withCheckedContinuation { continuation in
            var didResume = false
            recognizer.recognitionTask(with: request) { result, error in
                guard !didResume else { return }
                if let result, result.isFinal {
                    didResume = true
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else if error != nil {
                    didResume = true
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    /// Rough 0...1 loudness of a buffer for the wave.
    private static func rms(of buffer: AVAudioPCMBuffer) -> Float {
        guard let channel = buffer.floatChannelData?[0] else { return 0 }
        let count = Int(buffer.frameLength)
        guard count > 0 else { return 0 }
        var sum: Float = 0
        for i in 0..<count {
            let sample = channel[i]
            sum += sample * sample
        }
        let rms = sqrt(sum / Float(count))
        return min(1, rms * 8)
    }
}
