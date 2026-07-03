//
//  RecordingRepository.swift
//  VoiceNotes
//
//  The repository is the single seam between the ViewModels and the data
//  layer. ViewModels depend only on this protocol — they never touch
//  SwiftData or FileManager directly. The real SwiftData-backed
//  implementation lands in the logic pass; for now a mock returns samples.
//

import Foundation

protocol RecordingRepository {
    func fetchAll() -> [Recording]
    func save(_ recording: Recording)
    func delete(_ recording: Recording)
    func rename(_ recording: Recording, to newTitle: String)
}

/// In-memory mock backing the UI scaffold.
final class MockRecordingRepository: RecordingRepository {
    private var storage: [Recording]

    init(seed: [Recording] = Recording.samples) {
        self.storage = seed
    }

    func fetchAll() -> [Recording] {
        storage.sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ recording: Recording) {
        storage.insert(recording, at: 0)
    }

    func delete(_ recording: Recording) {
        storage.removeAll { $0.id == recording.id }
    }

    func rename(_ recording: Recording, to newTitle: String) {
        recording.title = newTitle
    }
}
