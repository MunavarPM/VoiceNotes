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
                .font(.rowCaption)
                .foregroundStyle(.secondary)

            Text(recording.title)
                .font(.recordingTitle)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .onTapGesture(perform: onOpen)

            playerRow
        }
        .padding(.vertical, 4)
    }

    private var playerRow: some View {
        HStack(spacing: 12) {
            if compact {
                // iOS: play + duration inside a compact capsule.
                HStack(spacing: 8) {
                    PlayButton(isPlaying: isPlaying, action: onPlayPause)
                    Text(recording.duration.durationString)
                        .font(.rowCaption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.fieldFill, in: Capsule())
                Spacer(minLength: 12)
            } else {
                // macOS: play + scrubber + duration grouped inside a capsule.
                HStack(spacing: 12) {
                    PlayButton(isPlaying: isPlaying, action: onPlayPause)
                    ProgressBarView(
                        progress: Binding(get: { progress }, set: onSeek)
                    )
                    Text(recording.duration.durationString)
                        .font(.rowCaption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.fieldFill, in: Capsule())
            }

            actionIcons
        }
    }

    private var actionIcons: some View {
        HStack(spacing: 8) {
            if showsNoteIcon {
                iconBadge("doc.text")
            }
            iconBadge("checkmark.circle")
            Button(action: onShare) {
                iconBadge("paperplane")
            }
            .buttonStyle(.plain)
            Menu {
                Button("Open Player", action: onOpen)
                Button("Rename", action: onRename)
                Button("Share", action: onShare)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                iconBadge("ellipsis")
            }
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .foregroundStyle(.primary)
    }

    /// An action glyph inside a circular darkGrayish background.
    private func iconBadge(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14))
            .frame(width: 30, height: 30)
            .background(Color.fieldFill, in: Circle())
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
