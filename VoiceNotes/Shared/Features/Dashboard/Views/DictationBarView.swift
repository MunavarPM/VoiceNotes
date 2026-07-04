//
//  DictationBarView.swift
//  VoiceNotes
//
//  Floating "listening" bar shown while Ask AI dictation is active: a live
//  voice-reactive wave + a stop button. The recognized text streams into
//  the search field (handled by the ViewModel), not here.
//

import SwiftUI

struct DictationBarView: View {
    let level: CGFloat
    var onStop: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Color.fieldFill
                WaterWaveView(level: level)
                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                    Text("Listening…")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            }
            .frame(height: 46)
            .clipShape(Capsule())

            Button(action: onStop) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 46, height: 46)
                    .background(Color.fieldFill, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.appBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 14, y: 4)
    }
}

#Preview {
    DictationBarView(level: 0.6) {}
        .padding(40)
}
