//
//  WaveformService.swift
//  VoiceNotes
//
//  Turns a raw stream of live power samples into a fixed number of
//  normalized bars for display/storage.
//

import Foundation

protocol WaveformService {
    /// Downsamples `samples` to `count` averaged bars (0...1).
    func resample(_ samples: [Float], to count: Int) -> [Float]
}

final class DefaultWaveformService: WaveformService {
    func resample(_ samples: [Float], to count: Int) -> [Float] {
        guard count > 0, !samples.isEmpty else { return [] }
        guard samples.count > count else { return samples }

        let bucketSize = Double(samples.count) / Double(count)
        return (0..<count).map { index in
            let start = Int(Double(index) * bucketSize)
            let end = min(samples.count, max(start + 1, Int(Double(index + 1) * bucketSize)))
            let slice = samples[start..<end]
            return slice.reduce(0, +) / Float(slice.count)
        }
    }
}
