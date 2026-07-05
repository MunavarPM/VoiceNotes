//
//  PlayerView.swift
//  VoiceNotes
//
//  Expanded player sheet with the recording's real stored waveform and a
//  full seekable scrubber. Controls the shared player, so it stays in sync
//  with inline playback on the dashboard.
//

import SwiftUI

struct PlayerView: View {
    @State private var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: PlayerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 22) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            VStack(spacing: 6) {
                Text(viewModel.recording.title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(viewModel.recording.createdAt.recordingCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            if viewModel.waveform.isEmpty {
                Image(systemName: "waveform")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.waveform.opacity(0.2))
                    .frame(height: 80)
            } else {
                WaveformView(samples: viewModel.waveform)
                    .frame(height: 80)
                    .padding(.horizontal)
            }

            VStack(spacing: 6) {
                ProgressBarView(
                    progress: Binding(
                        get: { viewModel.progress },
                        set: { viewModel.seek(to: $0) }
                    )
                )
                HStack {
                    Text(viewModel.elapsed.durationString)
                    Spacer()
                    Text(viewModel.recording.duration.durationString)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
            .padding(.horizontal)

            PlayButton(isPlaying: viewModel.isPlaying, size: 68, filled: true) {
                viewModel.togglePlay()
            }
            .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .padding()
        .frame(minWidth: 320, minHeight: 440)
        .background(Color.appBackground)
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(Color.fieldFill, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(12)
        }
    }
}

#Preview {
    PlayerView(viewModel: PlayerViewModel(recording: Recording.samples[0], player: AudioPlayerService()))
}
