//
//  DashboardViewModel.swift
//  VoiceNotes
//
//  Business logic for the dashboard: loading/filtering recordings and
//  driving the recording state. Talks only to the Repository and Services
//  — never to SwiftData/AVFoundation directly.
//

import Foundation
import Observation

enum RecordingFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case shared = "Shared"
    case starred = "Starred"

    var id: String { rawValue }
}

@Observable
final class DashboardViewModel {
    // State the views observe
    var recordings: [Recording] = []
    var searchText: String = ""
    var filter: RecordingFilter = .all
    var isRecording: Bool = false
    var recordingDuration: TimeInterval = 138   // mock 02:18 from the design
    var waveformSamples: [Float] = []
    var currentlyPlaying: Recording.ID?
    var showAskAI = false
    var showSettings = false

    // Dependencies (injected; defaulted to stubs for the scaffold)
    private let repository: RecordingRepository
    private let waveformService: WaveformService
    private let recorder: AudioRecorderService

    init(
        repository: RecordingRepository = MockRecordingRepository(),
        waveformService: WaveformService = StubWaveformService(),
        recorder: AudioRecorderService = StubAudioRecorderService()
    ) {
        self.repository = repository
        self.waveformService = waveformService
        self.recorder = recorder
        self.waveformSamples = waveformService.makeSamples(count: AppConstants.Layout.waveformBarCount)
        loadRecordings()
    }

    func loadRecordings() {
        recordings = repository.fetchAll()
    }

    var filteredRecordings: [Recording] {
        recordings
            .filter { recording in
                switch filter {
                case .all: true
                case .shared: recording.isShared
                case .starred: recording.isStarred
                }
            }
            .filter { recording in
                searchText.isEmpty || recording.title.localizedCaseInsensitiveContains(searchText)
            }
    }

    // MARK: - Recording (mock)

    func startNewRecording() {
        try? recorder.startRecording()
        isRecording = true
    }

    func stopRecording() {
        _ = recorder.stopRecording()
        isRecording = false
    }

    func toggleRecording() {
        isRecording ? stopRecording() : startNewRecording()
    }

    // MARK: - Mutations

    func delete(_ recording: Recording) {
        repository.delete(recording)
        loadRecordings()
    }

    func rename(_ recording: Recording, to newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        repository.rename(recording, to: trimmed)
        loadRecordings()
    }
}
