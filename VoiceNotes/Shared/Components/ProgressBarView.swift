//
//  ProgressBarView.swift
//  VoiceNotes
//
//  Seekable playback progress bar with a draggable knob.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double
    var height: CGFloat = 4
    var knobSize: CGFloat = 11

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let clamped = min(max(progress, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: height)

                Capsule()
                    .fill(Color.primary)
                    .frame(width: width * clamped, height: height)

                Circle()
                    .fill(Color.primary)
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: width * clamped - knobSize / 2)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        progress = min(max(value.location.x / width, 0), 1)
                    }
            )
        }
        .frame(height: max(knobSize, height))
    }
}

#Preview {
    ProgressBarView(progress: .constant(0.4))
        .padding()
}
