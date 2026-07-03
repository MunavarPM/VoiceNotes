//
//  WaveformService.swift
//  VoiceNotes
//
//  Converts audio power levels into normalized waveform bars.
//  Stub returns a smooth synthetic waveform so the UI animates.
//

import Foundation

protocol WaveformService {
    func makeSamples(count: Int) -> [Float]
}

final class StubWaveformService: WaveformService {
    func makeSamples(count: Int) -> [Float] {
        (0..<count).map { index in
            let wave = sin(Double(index) * 0.45) + sin(Double(index) * 0.17)
            let normalized = (wave + 2) / 4          // map roughly to 0...1
            return Float(0.2 + normalized * 0.7)
        }
    }
}
