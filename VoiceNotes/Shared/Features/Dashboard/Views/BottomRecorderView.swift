//
//  BottomRecorderView.swift
//  VoiceNotes
//
//  Floating recorder card: chevron handle, live waveform + timer, and the
//  Done button (black on macOS, green on iOS — per the mockups).
//

import SwiftUI

struct BottomRecorderView: View {
    let samples: [Float]
    let duration: TimeInterval
    var onDone: () -> Void
    var onExpand: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onExpand) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(7)
                    .background(Color.appBackground, in: Circle())
                    .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
            }
            .buttonStyle(.plain)
            .offset(y: 12)
            .zIndex(1)

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(.red)
                    WaveformView(samples: samples)
                        .frame(height: 24)
                    Text(duration.durationString)
                        .monospacedDigit()
                }
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.fieldFill, in: Capsule())

                doneButton
            }
            .padding(14)
            .background(Color.appBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 14, y: 4)
        }
    }

    private var doneButton: some View {
        Button(action: onDone) {
            label
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var label: some View {
        #if os(iOS)
        HStack(spacing: 6) {
            Image(systemName: "checkmark")
            Text(AppConstants.doneTitle)
        }
        .font(.headline)
        .foregroundStyle(Color.doneGreenText)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.doneGreen, in: Capsule())
        #else
        Text(AppConstants.doneTitle)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black, in: Capsule())
        #endif
    }
}

#Preview {
    BottomRecorderView(samples: Recording.previewWaveform, duration: 138) {}
        .padding(40)
}
