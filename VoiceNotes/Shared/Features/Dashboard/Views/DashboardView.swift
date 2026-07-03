//
//  DashboardView.swift
//  VoiceNotes
//
//  Shared dashboard screen used by both iOS and macOS. Platform
//  differences (large title, filter chips, layout) are handled inline
//  with #if, keeping ~95% of the code shared.
//

import SwiftUI

struct DashboardView: View {
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
                        samples: viewModel.waveformSamples,
                        duration: viewModel.recordingDuration,
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
            .sheet(item: $playerRecording) { recording in
                PlayerView(viewModel: PlayerViewModel(recording: recording))
                    #if os(macOS)
                    .frame(width: 440, height: 520)
                    #endif
            }
            .sheet(isPresented: $viewModel.showAskAI) { placeholderSheet(icon: "sparkles", title: AppConstants.askAI, message: "AI assistant coming soon.") { viewModel.showAskAI = false } }
            .sheet(isPresented: $viewModel.showSettings) { placeholderSheet(icon: "gearshape", title: "Settings", message: "Settings coming soon.") { viewModel.showSettings = false } }
            .alert("Rename Recording", isPresented: renameAlertBinding) {
                TextField("Title", text: $renameText)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    if let target = renameTarget { viewModel.rename(target, to: renameText) }
                }
            }
        }
    }

    // MARK: - Content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Layout.cardSpacing) {
                #if os(iOS)
                Text(AppConstants.appName)
                    .font(.largeTitle.bold())
                    .padding(.top, 4)
                #endif

                SearchBarView(text: $viewModel.searchText) { viewModel.showAskAI = true }

                #if os(iOS)
                FilterChipsView(selection: $viewModel.filter)
                #endif

                LazyVStack(alignment: .leading, spacing: AppConstants.Layout.cardSpacing) {
                    ForEach(viewModel.filteredRecordings) { recording in
                        RecordingCardView(
                            recording: recording,
                            compact: isCompactLayout,
                            onPlay: { playerRecording = recording },
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
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 160)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                withAnimation(.spring(response: 0.35)) { viewModel.startNewRecording() }
            } label: {
                Image(systemName: "plus")
            }
            Button {} label: { Image(systemName: "calendar") }
            Button { viewModel.showSettings = true } label: { Image(systemName: "gearshape") }
        }
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
}
