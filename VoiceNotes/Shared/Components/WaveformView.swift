//
//  WaveformView.swift
//  VoiceNotes
//
//  Renders normalized [Float] samples as a row of rounded bars.
//

import SwiftUI

struct WaveformView: View {
    let samples: [Float]
    var color: Color = .waveform
    var spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: spacing) {
                ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                    Capsule()
                        .fill(color)
                        .frame(height: max(3, CGFloat(sample) * geo.size.height))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    WaveformView(samples: StubWaveformService().makeSamples(count: 40))
        .frame(height: 40)
        .padding()
}
