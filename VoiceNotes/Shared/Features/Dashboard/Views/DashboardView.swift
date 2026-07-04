//
//  DashboardView.swift
//  VoiceNotes
//
//  Shared dashboard used by iOS and macOS. Records real audio, persists via
//  SwiftData, and plays back inline. Platform differences (large title,
//  filter chips, seek bar) are handled inline with #if.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @State private var playerRecording: Recording?
    @State private var renameTarget: Recording?
    @State private var renameText: String = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                scrollContent

                if viewModel.isRecording {
                    BottomRecorderView(
                        samples: viewModel.liveWaveform,
                        duration: viewModel.recordingElapsed,
                        onDone: { withAnimation(.spring(response: 0.35)) { viewModel.stopRecording() } }
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color.appBackground)
            .toolbar { toolbarContent }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task { viewModel.configure(context: modelContext) }
            .sheet(item: $playerRecording) { recording in
                PlayerView(viewModel: PlayerViewModel(recording: recording, player: viewModel.player))
                    #if os(macOS)
                    .frame(width: 440, height: 520)
                    #endif
            }
            .sheet(isPresented: $viewModel.showAskAI) {
                placeholderSheet(icon: "sparkles", title: AppConstants.askAI, message: "AI assistant coming soon.") { viewModel.showAskAI = false }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                placeholderSheet(icon: "gearshape", title: "Settings", message: "Settings coming soon.") { viewModel.showSettings = false }
            }
            .alert("Rename Recording", isPresented: renameAlertBinding) {
                TextField("Title", text: $renameText)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    if let target = renameTarget { viewModel.rename(target, to: renameText) }
                }
            }
            .alert("Microphone Access Needed", isPresented: $viewModel.permissionDenied) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Enable microphone access in Settings to record voice notes.")
            }
        }
    }

    // MARK: - Content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Layout.cardSpacing) {
                #if os(iOS)
                Text(AppConstants.appName)
                    .font(.appLargeTitle)
                    .padding(.top, 4)
                #endif

                SearchBarView(text: $viewModel.searchText) { viewModel.showAskAI = true }

                #if os(iOS)
                FilterChipsView(selection: $viewModel.filter)
                #endif

                if viewModel.filteredRecordings.isEmpty {
                    emptyState
                } else {
                    recordingList
                }
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 160)
        }
    }

    private var recordingList: some View {
        LazyVStack(alignment: .leading, spacing: AppConstants.Layout.cardSpacing) {
            ForEach(viewModel.filteredRecordings) { recording in
                RecordingCardView(
                    recording: recording,
                    compact: isCompactLayout,
                    isPlaying: viewModel.isPlaying(recording),
                    progress: viewModel.progress(for: recording),
                    onPlayPause: { viewModel.togglePlayback(for: recording) },
                    onSeek: { viewModel.seek(recording, to: $0) },
                    onOpen: { playerRecording = recording },
                    onRename: {
                        renameTarget = recording
                        renameText = recording.title
                    },
                    onShare: {},
                    onDelete: { withAnimation { viewModel.delete(recording) } }
                )
                Divider()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 46))
                .foregroundStyle(Color.waveform)
            Text("No recordings yet")
                .font(.headline)
            Text("Tap ＋ to record your first voice note.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                Task { await startRecordingAnimated() }
            } label: {
                Image(systemName: "plus")
            }
            .disabled(viewModel.isRecording)
            Button {} label: { Image(systemName: "calendar") }
            Button { viewModel.showSettings = true } label: { Image(systemName: "gearshape") }
        }
    }

    private func startRecordingAnimated() async {
        await viewModel.startRecording()
        withAnimation(.spring(response: 0.35)) {}
    }

    // MARK: - Helpers

    private var isCompactLayout: Bool {
        #if os(iOS)
        true
        #else
        false
        #endif
    }

    private var renameAlertBinding: Binding<Bool> {
        Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )
    }

    private func placeholderSheet(icon: String, title: String, message: String, onClose: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.waveform)
            Text(title).font(.title2.bold())
            Text(message).foregroundStyle(.secondary)
            Button("Close", action: onClose)
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(minWidth: 300, minHeight: 260)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Recording.self, inMemory: true)
}
