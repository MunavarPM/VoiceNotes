//
//  PlayButton.swift
//  VoiceNotes
//
//  Reusable play/pause toggle. `filled` draws a solid circular button
//  for the expanded player; otherwise it's a bare glyph for list rows.
//

import SwiftUI

struct PlayButton: View {
    var isPlaying: Bool
    var size: CGFloat = 24
    var filled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: filled ? size * 0.4 : size * 0.55, weight: .bold))
                .foregroundStyle(filled ? Color.white : Color.primary)
                .frame(width: size, height: size)
                .background {
                    if filled { Circle().fill(Color.primary) }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 20) {
        PlayButton(isPlaying: false) {}
        PlayButton(isPlaying: true, size: 64, filled: true) {}
    }
    .padding()
}
