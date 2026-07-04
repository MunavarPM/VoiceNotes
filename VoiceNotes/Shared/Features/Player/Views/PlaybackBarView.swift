//
//  PlaybackBarView.swift
//  VoiceNotes
//
//  Floating "now playing" control bar shown at the bottom while a recording
//  plays: speed, skip ±, play/pause, seek scrubber, times, and close.
//  Driven by the shared AudioPlayerService, so it stays in sync with the
//  list rows and the expanded player. Shared across iOS and macOS.
//

import SwiftUI

struct PlaybackBarView: View {
    let player: AudioPlayerService

    var body: some View {
        HStack(spacing: 12) {
            Button(action: player.cycleRate) {
                Text(rateLabel)
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 32)
            }
            .buttonStyle(.plain)

            Button { player.skip(by: -15) } label: {
                Image(systemName: "gobackward.15")
            }
            .buttonStyle(.plain)

            Button(action: player.togglePlayPause) {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .frame(width: 22)
            }
            .buttonStyle(.plain)

            Button { player.skip(by: 30) } label: {
                Image(systemName: "goforward.30")
            }
            .buttonStyle(.plain)

            Text(player.elapsed.durationString)
                .font(.rowCaption)
                .monospacedDigit()
                .foregroundStyle(.secondary)

            ProgressBarView(
                progress: Binding(get: { player.progress }, set: { player.seek(to: $0) })
            )
            .layoutPriority(1)

            Text(player.duration.durationString)
                .font(.rowCaption)
                .monospacedDigit()
                .foregroundStyle(.secondary)

            Button(action: player.stop) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 17))
        .foregroundStyle(.primary)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.appBackground, in: Capsule())
        .overlay(Capsule().stroke(Color.fieldFill, lineWidth: 1))
        .shadow(color: .black.opacity(0.12), radius: 14, y: 4)
    }

    private var rateLabel: String {
        rate == rate.rounded()
            ? String(format: "%.0fx", rate)
            : String(format: "%.1fx", rate)
    }

    private var rate: Float { player.rate }
}

#Preview {
    PlaybackBarView(player: AudioPlayerService())
        .padding()
}
