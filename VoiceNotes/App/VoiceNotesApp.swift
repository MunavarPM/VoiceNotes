//
//  VoiceNotesApp.swift
//  VoiceNotes
//
//  Single @main entry point shared across iOS and macOS. RootView selects
//  the platform-specific wrapper. SwiftData runs in-memory for the UI
//  scaffold; disk persistence lands in the logic pass.
//

import SwiftUI
import SwiftData

@main
struct VoiceNotesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Recording.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
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
