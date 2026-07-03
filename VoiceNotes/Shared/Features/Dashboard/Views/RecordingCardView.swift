//
//  RecordingCardView.swift
//  VoiceNotes
//
//  A single recording row. Playback state (isPlaying/progress) is supplied
//  by the dashboard's shared player. `compact` (iOS) hides the scrub bar
//  and shows just play + duration, matching the mockups; macOS shows the
//  full seekable bar. Tapping the title opens the expanded player.
//

import SwiftUI

struct RecordingCardView: View {
    let recording: Recording
    var compact: Bool = false
    var isPlaying: Bool = false
    var progress: Double = 0
    var showsNoteIcon: Bool = true
    var onPlayPause: () -> Void = {}
    var onSeek: (Double) -> Void = { _ in }
    var onOpen: () -> Void = {}
    var onRename: () -> Void = {}
    var onShare: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recording.createdAt.recordingCaption)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(recording.title)
                .font(.headline)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .onTapGesture(perform: onOpen)

            playerRow
        }
        .padding(.vertical, 4)
    }

    private var playerRow: some View {
        HStack(spacing: 12) {
            PlayButton(isPlaying: isPlaying, action: onPlayPause)

            if compact {
                Text(recording.duration.durationString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                Spacer(minLength: 12)
            } else {
                ProgressBarView(
                    progress: Binding(get: { progress }, set: onSeek)
                )
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
                Button("Open Player", action: onOpen)
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
        RecordingCardView(recording: Recording.samples[0], compact: false, isPlaying: true, progress: 0.4)
        Divider()
        RecordingCardView(recording: Recording.samples[1], compact: true)
    }
    .padding()
}
