# VoiceNotes — Architecture

A multiplatform (iOS + macOS) voice-notes app built from **one codebase** with
SwiftUI, SwiftData, and AVFoundation, following **MVVM + Services + Repository**.

> **Status:** UI scaffold. All screens are built and wired to mock/sample data.
> Real audio (AVFoundation), on-disk SwiftData persistence, and microphone
> permissions are staged for the next pass — see [Deferred](#deferred-to-the-logic-pass).

---

## 1. Project shape

- **One Xcode project, one multiplatform target** (`VoiceNotes`) with
  **Supported Destinations: iPhone, iPad, Mac**.
- **~95% shared code.** Only small layout tweaks are platform-specific,
  isolated with `#if os(iOS)` / `#if os(macOS)` and the thin `iOS/` + `macOS/`
  root wrappers.
- **Single `@main`** (`App/VoiceNotesApp.swift`). `RootView` picks the
  platform wrapper.
- **Minimum OS:** iOS 17 / macOS 14 (required for SwiftData + the
  `@Observable` Observation framework).

> **Divergence from the original spec:** the spec sketched two per-platform
> entry files (`iOS/AudioRecorderApp.swift`, `macOS/AudioRecorderApp.swift`).
> A single multiplatform target can only have one `@main`, so we use one shared
> entry point and keep the `iOS/` + `macOS/` folders for platform-specific
> _views_ instead. This is cleaner and truer to "one codebase."

---

## 2. Folder structure

```
VoiceNotes/
├── App/
│   └── VoiceNotesApp.swift          # single @main + RootView
├── Shared/
│   ├── Models/
│   │   └── Recording.swift          # @Model: id, title, filePath, duration, createdAt, isStarred, isShared
│   ├── Repository/
│   │   └── RecordingRepository.swift# protocol + MockRecordingRepository
│   ├── Services/
│   │   ├── AudioRecorderService.swift  # protocol + stub (AVAudioRecorder later)
│   │   ├── AudioPlayerService.swift    # protocol + stub (AVAudioPlayer later)
│   │   ├── WaveformService.swift       # protocol + stub (power → bars)
│   │   └── FileManagerService.swift    # protocol + stub (.m4a files)
│   ├── Features/
│   │   ├── Dashboard/
│   │   │   ├── Views/
│   │   │   │   ├── DashboardView.swift      # shared list screen
│   │   │   │   ├── SearchBarView.swift      # search + "Ask AI"
│   │   │   │   ├── FilterChipsView.swift    # All / Shared / Starred (iOS)
│   │   │   │   ├── RecordingCardView.swift  # row: date, title, inline player, actions
│   │   │   │   └── BottomRecorderView.swift # floating recorder + Done
│   │   │   └── ViewModels/
│   │   │       └── DashboardViewModel.swift
│   │   └── Player/
│   │       ├── Views/PlayerView.swift
│   │       └── ViewModels/PlayerViewModel.swift
│   ├── Components/
│   │   ├── WaveformView.swift        # [Float] samples → bars
│   │   ├── PlayButton.swift
│   │   └── ProgressBarView.swift     # seekable
│   └── Core/
│       ├── Constants/AppConstants.swift
│       ├── Extensions/               # Date+Format, Color+Theme
│       └── Helpers/SampleData.swift  # Recording.samples
├── iOS/
│   └── PlatformRootView.swift        # #if os(iOS)
└── macOS/
    └── PlatformRootView.swift        # #if os(macOS)
```

> The target uses **file-system synchronized groups**, so any file added under
> `VoiceNotes/` is compiled automatically — no `.pbxproj` bookkeeping.

---

## 3. Layers (MVVM + Services + Repository)

**View** — SwiftUI only. Shows UI, forwards taps to the ViewModel. No logic.
`DashboardView`, `RecordingCardView`, `BottomRecorderView`, `PlayerView`, etc.

**ViewModel** — `@Observable` business logic. Holds `isRecording`,
`waveformSamples`, `recordings`, `searchText`, `filter`, `currentlyPlaying`;
formats data; orchestrates services + repository. `DashboardViewModel`,
`PlayerViewModel`.

**Model** — data only. `Recording` (`@Model`).

**Services** — the real work (later pass): `AudioRecorderService`
(AVAudioRecorder, permission, metering), `AudioPlayerService` (AVAudioPlayer,
play/pause/seek), `WaveformService` (power → bars), `FileManagerService`
(`.m4a` save/delete). Each is a **protocol** with a stub conformer today.

**Repository** — `RecordingRepository` is the only seam to persistence. The
ViewModel never sees SwiftData or FileManager; it calls `fetchAll / save /
delete / rename`. Swapping `MockRecordingRepository` for a SwiftData-backed one
requires **zero ViewModel changes**.

---

## 4. Data flow

```
Recording:  DashboardView → DashboardViewModel → AudioRecorderService → (AVAudioRecorder)
                                              ↘ RecordingRepository → (SwiftData)

Playback:   RecordingCardView → PlayerView → PlayerViewModel → AudioPlayerService → (AVAudioPlayer)
```

---

## 5. What's functional in the scaffold

- Recording list rendered from the mock repository (sorted by date).
- Search filtering + **All / Shared / Starred** chips (iOS).
- Floating recorder toggled by `+` / `Done` (mock waveform + timer).
- Tap a card → expanded **PlayerView** sheet (mock play/pause/seek).
- Card `…` menu → **Rename** (alert) / **Share** / **Delete** (real against mock data).
- **Ask AI** and **Settings** open placeholder sheets.

---

## Deferred to the logic pass

- Real `AVAudioRecorder` / `AVAudioPlayer`; live metering → waveform; real seek.
- SwiftData persistence to disk (currently `isStoredInMemoryOnly: true`) behind a
  real `RecordingRepository`.
- **Mic permission:** `INFOPLIST_KEY_NSMicrophoneUsageDescription` + a macOS
  entitlements file with `com.apple.security.device.audio-input` (App Sandbox is on).
- `.m4a` file save/delete in Documents; universal app icon.
