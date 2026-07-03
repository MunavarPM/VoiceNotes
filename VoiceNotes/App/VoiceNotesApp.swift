//
//  VoiceNotesApp.swift
//  VoiceNotes
//
//  Single @main entry point shared across iOS and macOS. SwiftData now
//  persists recordings to disk.
//

import SwiftUI
import SwiftData

@main
struct VoiceNotesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Recording.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif
    }
}

struct RootView: View {
    var body: some View {
        PlatformRootView()
    }
}
