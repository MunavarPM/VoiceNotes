//
//  DashboardViewModel.swift
//  VoiceNotes
//
//  Owns dashboard state and orchestrates the services + repository. It
//  never touches SwiftData/AVFoundation directly. Playback is delegated to
//  the shared @Observable AudioPlayerService so all views stay in sync.
//

import Foundation
import SwiftData
import Observation

enum RecordingFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case shared = "Shared"
    case starred = "Starred"

    var id: String { rawValue }
}

@Observable
final class DashboardViewModel {
    // Displayed state
    var recordings: [Recording] = []
    var searchText: String = ""
    var filter: RecordingFilter = .all
    var showAskAI = false
    var showSettings = false

    // Recording state
    var isRecording = false
    var recordingElapsed: TimeInterval = 0
    var liveWaveform: [Float] = []
    /// Smoothed 0...1 mic level driving the live waveform amplitude.
    var liveLevel: CGFloat = 0
    var permissionDenied = false

    /// Shared playback service — the single source of truth for playback.
    let player: AudioPlayerService

    private let recorder: AudioRecorderService
    private let waveformService: WaveformService
    private let fileManager: FileManagerService
    private var repository: RecordingRepository?

    private var recordingURL: URL?
    private var capturedSamples: [Float] = []
    private var meterTask: Task<Void, Never>?

    private let liveBarCount = 40
    private let storedBarCount = 50

    init(
        player: AudioPlayerService = AudioPlayerService(),
        recorder: AudioRecorderService = DefaultAudioRecorderService(),
        waveformService: WaveformService = DefaultWaveformService(),
        fileManager: FileManagerService = DefaultFileManagerService()
    ) {
        self.player = player
        self.recorder = recorder
        self.waveformService = waveformService
        self.fileManager = fileManager
    }

    /// Wire up SwiftData once the view provides the ModelContext.
    func configure(context: ModelContext) {
        guard repository == nil else { return }
        repository = SwiftDataRecordingRepository(context: context)
        loadRecordings()
    }

    func loadRecordings() {
        recordings = repository?.fetchAll() ?? []
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

    // MARK: - Recording

    func startRecording() async {
        guard !isRecording else { return }
        let granted = await recorder.requestPermission()
        guard granted else {
            permissionDenied = true
            return
        }

        let url = fileManager.newRecordingURL()
        do {
            try recorder.start(url: url)
            recordingURL = url
            capturedSamples = []
            liveWaveform = []
            liveLevel = 0
            recordingElapsed = 0
            isRecording = true
            startMetering()
        } catch {
            isRecording = false
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        meterTask?.cancel()
        meterTask = nil

        let duration = recorder.stop()
        isRecording = false

        guard let url = recordingURL, duration > 0.3 else {
            // Too short / failed — clean up the empty file.
            if let url = recordingURL { try? fileManager.delete(fileName: url.lastPathComponent) }
            recordingURL = nil
            return
        }

        let bars = waveformService.resample(capturedSamples, to: storedBarCount)
        let recording = Recording(
            title: defaultTitle(),
            filePath: url.lastPathComponent,
            duration: duration,
            waveform: bars
        )
        repository?.save(recording)
        loadRecordings()
        recordingURL = nil
    }

    private func startMetering() {
        meterTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 50_000_000) // 20 Hz
                guard let self, self.isRecording else { return }
                let power = self.recorder.currentPower()
                self.capturedSamples.append(power)
                self.recordingElapsed += 0.05

                // Exponential smoothing so the wave reacts to the voice but
                // doesn't jitter.
                self.liveLevel = self.liveLevel * 0.8 + CGFloat(power) * 0.2

                var tail = self.liveWaveform
                tail.append(power)
                if tail.count > self.liveBarCount {
                    tail.removeFirst(tail.count - self.liveBarCount)
                }
                self.liveWaveform = tail
            }
        }
    }

    private func defaultTitle() -> String {
        "New Recording · " + Date().formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: - Playback (delegated to the shared player)

    func togglePlayback(for recording: Recording) {
        guard !recording.filePath.isEmpty else { return }
        let url = fileManager.url(forFileName: recording.filePath)
        player.toggle(url: url, fileName: recording.filePath)
    }

    func isPlaying(_ recording: Recording) -> Bool {
        player.currentFileName == recording.filePath && player.isPlaying
    }

    func isActive(_ recording: Recording) -> Bool {
        player.currentFileName == recording.filePath
    }

    func progress(for recording: Recording) -> Double {
        isActive(recording) ? player.progress : 0
    }

    func seek(_ recording: Recording, to fraction: Double) {
        guard isActive(recording) else { return }
        player.seek(to: fraction)
    }

    // MARK: - Mutations

    func delete(_ recording: Recording) {
        if isActive(recording) { player.stop() }
        try? fileManager.delete(fileName: recording.filePath)
        repository?.delete(recording)
        loadRecordings()
    }

    func rename(_ recording: Recording, to newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        repository?.rename(recording, to: trimmed)
        loadRecordings()
    }
}
