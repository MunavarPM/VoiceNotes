//
//  WaterWaveView.swift
//  VoiceNotes
//
//  A smooth, continuously animated "water wave" that matches the Figma:
//  one solid periwinkle body plus a lighter band sitting slightly higher,
//  filling roughly the lower 40% with a gentle undulating surface.
//  Driven by TimelineView so it animates identically on iOS and macOS.
//

import SwiftUI

struct WaterWaveView: View {
    var color: Color = .waterWave
    /// Live 0...1 input level (from mic power). Higher = taller waves;
    /// near 0 = an almost flat, calm surface.
    var level: CGFloat = 0.5

    private let layers: [WaveLayer] = [
        // A single, solid periwinkle wave.
        WaveLayer(fill: 0.42, amplitude: 1.0, opacity: 1.0, speed: 1.3, phase: 0, frequency: 1.4)
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for layer in layers {
                    context.fill(path(for: layer, in: size, time: time),
                                 with: .color(color.opacity(layer.opacity)))
                }
            }
        }
    }

    private func path(for layer: WaveLayer, in size: CGSize, time: Double) -> Path {
        let surfaceY = size.height * (1 - layer.fill)
        let clampedLevel = max(0.05, min(1, level))
        let waveHeight = size.height * 0.22 * layer.amplitude * clampedLevel
        let phase = time * layer.speed + layer.phase
        let width = max(size.width, 1)

        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height))

        var x: CGFloat = 0
        while x <= size.width {
            let relative = Double(x / width)
            let y = surfaceY + waveHeight * CGFloat(sin(relative * .pi * 2 * layer.frequency + phase))
            path.addLine(to: CGPoint(x: x, y: y))
            x += 2
        }

        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()
        return path
    }
}

private struct WaveLayer {
    /// Water level as a fraction of height (0 = empty, 1 = full).
    let fill: CGFloat
    let amplitude: CGFloat
    let opacity: Double
    let speed: Double
    let phase: Double
    let frequency: Double
}

#Preview {
    WaterWaveView()
        .frame(width: 340, height: 54)
        .background(Color.fieldFill)
        .clipShape(Capsule())
        .padding()
}
