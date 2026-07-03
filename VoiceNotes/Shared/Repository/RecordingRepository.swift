//
//  RecordingRepository.swift
//  VoiceNotes
//
//  The single seam between ViewModels and persistence. ViewModels depend
//  only on this protocol; the SwiftData details live here. Swapping the
//  backing store requires zero ViewModel changes.
//

import Foundation
import SwiftData

protocol RecordingRepository {
    func fetchAll() -> [Recording]
    func save(_ recording: Recording)
    func delete(_ recording: Recording)
    func rename(_ recording: Recording, to newTitle: String)
}

/// SwiftData-backed repository — real, persisted storage.
final class SwiftDataRecordingRepository: RecordingRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() -> [Recording] {
        let descriptor = FetchDescriptor<Recording>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func save(_ recording: Recording) {
        context.insert(recording)
        try? context.save()
    }

    func delete(_ recording: Recording) {
        context.delete(recording)
        try? context.save()
    }

    func rename(_ recording: Recording, to newTitle: String) {
        recording.title = newTitle
        try? context.save()
    }
}
