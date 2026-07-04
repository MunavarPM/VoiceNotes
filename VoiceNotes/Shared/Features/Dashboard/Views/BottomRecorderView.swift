//
//  BottomRecorderView.swift
//  VoiceNotes
//
//  Floating recorder card: chevron handle, live blue waveform + timer on a
//  light lime-green pill, and the Done button — lime green on iOS, black on
//  macOS (per the mockups).
//

import SwiftUI

struct BottomRecorderView: View {
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
                ZStack {
                    Color.fieldFill
                    WaterWaveView()
                    HStack(spacing: 8) {
                        Image(systemName: "pause.fill")
                        Text(duration.durationString)
                            .monospacedDigit()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
                .frame(height: 54)
                .clipShape(Capsule())

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
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.limeGreen, in: Capsule())
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
    BottomRecorderView(duration: 138) {}
        .padding(40)
}
