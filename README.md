# VoiceNotes

A multiplatform (iOS + macOS) voice-notes app built from a single SwiftUI
codebase using **SwiftData**, **AVFoundation**, and an **MVVM + Services +
Repository** architecture with a live waveform.

See **[Architecture.md](Architecture.md)** for the full design.

## Status

**UI scaffold** — all iOS + macOS screens are built and wired to mock/sample
data. Real recording/playback, on-disk persistence, and mic permissions are
staged for the next pass (documented in `Architecture.md`).

## Requirements

- Xcode 16+ (project created with Xcode 26.5)
- iOS 17.0+ / macOS 14.0+

## Build & run

Open the project and pick a destination (a Mac, or an iOS simulator):

```sh
open VoiceNotes.xcodeproj
```

Or from the command line:

```sh
# macOS
xcodebuild -project VoiceNotes.xcodeproj -scheme VoiceNotes -destination 'platform=macOS' build

# iOS simulator
xcodebuild -project VoiceNotes.xcodeproj -scheme VoiceNotes -destination 'platform=iOS Simulator,name=iPhone 16' build
```
