//
//  AudioRecorderService.swift
//  VoiceNotes
//
//  Owns AVAudioRecorder, mic permission, metering and start/stop.
//  This is a stub for the UI scaffold; the AVFoundation implementation
//  lands in the logic pass.
//

import Foundation

protocol AudioRecorderService: AnyObject {
    var isRecording: Bool { get }
    func startRecording() throws
    func stopRecording() -> URL?
    /// Normalized 0...1 power level for the live waveform.
    func currentPower() -> Float
}

final class StubAudioRecorderService: AudioRecorderService {
    private(set) var isRecording = false

    func startRecording() throws {
        isRecording = true
    }

    func stopRecording() -> URL? {
        isRecording = false
        return nil
    }

    func currentPower() -> Float {
        Float.random(in: 0.15...1.0)
    }
}
