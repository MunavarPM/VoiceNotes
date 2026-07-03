//
//  FileManagerService.swift
//  VoiceNotes
//
//  Handles saving/deleting .m4a files in the Documents directory.
//  Stub for the UI scaffold.
//

import Foundation

protocol FileManagerService {
    func documentsURL() -> URL
    func fileURL(for name: String) -> URL
    func delete(at url: URL) throws
}

final class StubFileManagerService: FileManagerService {
    func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func fileURL(for name: String) -> URL {
        documentsURL().appendingPathComponent(name).appendingPathExtension("m4a")
    }

    func delete(at url: URL) throws {
        // No-op in the scaffold.
    }
}
