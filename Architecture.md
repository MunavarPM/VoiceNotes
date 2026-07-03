# VoiceNotes — Architecture

A multiplatform (iOS + macOS) voice-notes app built from **one codebase** with
SwiftUI, SwiftData, and AVFoundation, following **MVVM + Services + Repository**.

> **Status:** Functional. Records real audio, persists to disk with SwiftData,
> and plays back with a live/stored waveform — on both iOS and macOS.

---

## 1. Project shape

- **One Xcode project, one multiplatform target** (`VoiceNotes`) with
  **Supported Destinations: iPhone, iPad, Mac**.
- **~95% shared code.** Only small layout tweaks and the audio-session /
  permission APIs are platform-specific, isolated with `#if os(iOS)` /
  `#if os(macOS)`.
- **Single `@main`** (`App/VoiceNotesApp.swift`); `RootView` picks the platform
  wrapper.
- **Minimum OS:** iOS 17 / macOS 14 (SwiftData + the `@Observable` framework).

> **Divergence from the original spec:** the spec sketched two per-platform
> entry files. A single multiplatform target has one `@main`, so we use one
> shared entry point and keep `iOS/` + `macOS/` for platform-specific views.

---

## 2. Folder structure

```
VoiceNotes/
├── App/VoiceNotesApp.swift          # single @main + RootView
├── Shared/
│   ├── Models/Recording.swift       # @Model: id, title, filePath, duration,
│   │                                #         createdAt, isStarred, isShared, waveform
│   ├── Repository/RecordingRepository.swift   # protocol + SwiftDataRecordingRepository
│   ├── Services/
│   │   ├── AudioRecorderService.swift   # protocol + AVAudioRecorder impl (+ permission, metering)
│   │   ├── AudioPlayerService.swift     # @Observable shared AVAudioPlayer (source of truth)
│   │   ├── WaveformService.swift        # protocol + downsampler (power → bars)
│   │   └── FileManagerService.swift     # protocol + .m4a files in Documents/Recordings
│   ├── Features/
│   │   ├── Dashboard/{Views, ViewModels}
│   │   └── Player/{Views, ViewModels}
│   ├── Components/                  # WaveformView, PlayButton, ProgressBarView
│   └── Core/{Constants, Extensions, Helpers}
├── iOS/IOSRootView.swift            # #if os(iOS)
└── macOS/MacRootView.swift          # #if os(macOS)
VoiceNotes.entitlements              # macOS App Sandbox + microphone (audio-input)
```

> The target uses **file-system synchronized groups**, so any file added under
> `VoiceNotes/` is compiled automatically.

---

## 3. Layers

**View** — SwiftUI only. **ViewModel** — `@Observable` logic (`DashboardViewModel`,
`PlayerViewModel`). **Model** — `Recording` (`@Model`). **Services** — the real
work. **Repository** — the only seam to persistence.

**Repository.** `RecordingRepository` is a protocol; `SwiftDataRecordingRepository`
is the on-disk implementation. The ViewModel calls `fetchAll / save / delete /
rename` and never sees SwiftData. The view passes its `ModelContext` into the
ViewModel via `configure(context:)`.

**Playback source of truth.** `AudioPlayerService` is a single **`@Observable`
shared** object injected into both ViewModels. Because it's the one place that
knows what's playing, only one recording plays at a time and the list row + the
expanded player stay perfectly in sync. (This is a deliberate, SwiftUI-idiomatic
choice: an `@Observable` service so the views observe playback directly.)

---

## 4. Data flow

```
Recording:  DashboardView → DashboardViewModel → AudioRecorderService → AVAudioRecorder
                          ↘ WaveformService (bars) ↘ RecordingRepository → SwiftData
                                                    ↘ FileManagerService → .m4a on disk

Playback:   RecordingCardView / PlayerView → ViewModel → AudioPlayerService (shared) → AVAudioPlayer
```

**Recording:** `+` → request mic permission → `AVAudioRecorder` writes an `.m4a`
to `Documents/Recordings/`, metering feeds the live waveform (20 Hz). **Done** →
duration + downsampled waveform saved as a `Recording` in SwiftData.

**Playback:** tap a row's play button (inline) or open the expanded player; both
drive the shared `AudioPlayerService` with real seek/scrub.

---

## 5. Cross-platform specifics

| Concern | iOS | macOS |
|---|---|---|
| Mic permission | `AVAudioApplication.requestRecordPermission` | `AVCaptureDevice.requestAccess(for: .audio)` |
| Audio session | `AVAudioSession` (playAndRecord / playback) | none (no `AVAudioSession` on macOS) |
| Mic entitlement | Info.plist usage string | `VoiceNotes.entitlements` → `com.apple.security.device.audio-input` + App Sandbox |
| Row layout | compact (play + duration, scrub in expanded player) | full inline seek bar |
| Done button | green pill w/ checkmark | black pill |

`INFOPLIST_KEY_NSMicrophoneUsageDescription` is set for both platforms.

---

## 6. Build & run

Open `VoiceNotes.xcodeproj`, pick a Mac or an iOS simulator, and run. First
recording prompts for microphone access. Verified with `xcodebuild` for both
`platform=macOS` and `platform=iOS Simulator`.

## Possible next steps

- Real waveform for imported/older files via `AVAssetReader`.
- iCloud sync (SwiftData + CloudKit).
- Functional Ask AI (transcription/summary) and Share.
- App icons.
