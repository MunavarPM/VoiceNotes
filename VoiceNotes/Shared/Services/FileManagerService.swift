//
//  FileManagerService.swift
//  VoiceNotes
//
//  Manages .m4a files inside the app's Documents/Recordings directory.
//  Works identically on iOS and macOS (each returns the app container's
//  Documents directory).
//

import Foundation

protocol FileManagerService {
    /// A fresh unique URL for a new recording (also ensures the directory exists).
    func newRecordingURL() -> URL
    /// Reconstructs a file URL from a stored file name.
    func url(forFileName name: String) -> URL
    func delete(fileName: String) throws
}

final class DefaultFileManagerService: FileManagerService {
    private let fileManager = FileManager.default

    private var recordingsDirectory: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("Recordings", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    func newRecordingURL() -> URL {
        recordingsDirectory
            .appendingPathComponent(UUID().uuidString) // a random unique name so never collide
            .appendingPathExtension("m4a")
    }

    func url(forFileName name: String) -> URL {
        recordingsDirectory.appendingPathComponent(name)
    }

    func delete(fileName: String) throws {
        let url = url(forFileName: fileName)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}
