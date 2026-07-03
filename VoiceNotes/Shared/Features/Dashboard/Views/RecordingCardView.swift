//
//  RecordingCardView.swift
//  VoiceNotes
//
//  A single recording row: date caption, title, inline player and the
//  trailing action icons. `compact` (iOS) hides the long progress bar and
//  shows just play + duration, matching the mockups.
//

import SwiftUI

struct RecordingCardView: View {
    let recording: Recording
    var compact: Bool = false
    var showsNoteIcon: Bool = true
    var onPlay: () -> Void = {}
    var onRename: () -> Void = {}
    var onShare: () -> Void = {}
    var onDelete: () -> Void = {}

    @State private var progress: Double = 0.6

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recording.createdAt.recordingCaption)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(recording.title)
                .font(.headline)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            playerRow
        }
        .padding(.vertical, 4)
    }

    private var playerRow: some View {
        HStack(spacing: 12) {
            PlayButton(isPlaying: false, action: onPlay)

            if compact {
                Text(recording.duration.durationString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                Spacer(minLength: 12)
            } else {
                ProgressBarView(progress: $progress)
                Text(recording.duration.durationString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            actionIcons
        }
    }

    private var actionIcons: some View {
        HStack(spacing: 14) {
            if showsNoteIcon {
                Image(systemName: "doc.text")
            }
            Image(systemName: "checkmark.circle")
            Button(action: onShare) {
                Image(systemName: "paperplane")
            }
            .buttonStyle(.plain)
            Menu {
                Button("Rename", action: onRename)
                Button("Share", action: onShare)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
            }
            .buttonStyle(.plain)
            .fixedSize()
        }
        .font(.system(size: 15))
        .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(spacing: 20) {
        RecordingCardView(recording: Recording.samples[0], compact: false)
        Divider()
        RecordingCardView(recording: Recording.samples[1], compact: true)
    }
    .padding()
}
