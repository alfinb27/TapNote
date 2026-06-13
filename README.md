# Tapnote 🎙️

A modern, fluid iOS voice recording application built entirely with SwiftUI and modern Swift concurrency. 

Tapnote demonstrates a cleanly decoupled MVVM architecture, real-time audio metering, background audio processing, and strict adherence to Swift 6 concurrency standards.

## ✨ Features
* **Real-Time Visualization:** Custom `SwiftUI Path` animations powered by `AVAudioRecorder` metering data for a smooth, responsive recording experience.
* **Interactive Playback:** Dynamic expanding list rows with inline scrubbing and a dedicated detailed playback screen.
* **File Management:** Safely save, rename, delete, and natively share `.m4a` recordings.
* **Smart Filtering:** Instant search and "Starred" filtering using a responsive `ObservableObject` state.
* **Background Support:** Full background audio recording and playback integration.
* **Graceful Permissions:** Native routing to iOS Settings for hardware microphone access management.
* **Haptics & Polish:** `UIImpactFeedbackGenerator` and `withAnimation` used throughout for a premium, tactile feel.

## 🏗️ Architecture (MVVM)
* **Services:** `AudioRecorderService` and `AudioPlayerService` independently manage `AVFoundation` hardware interactions, permissions, and timers.
* **ViewModels:** Strict `@MainActor` isolated controllers (`RecorderViewModel`, `VoiceNotesListViewModel`) that safely bridge hardware callbacks to the UI without data races.
* **Views:** Pure, state-driven SwiftUI components completely isolated from business logic.

## 🚀 Setup & Installation
1. Clone the repository.
2. Open `Tapnote.xcodeproj` in Xcode 15+.
3. Select an iPhone Simulator or a physical iOS device (iOS 16.0+ recommended).
4. Build and Run (`Cmd + R`).
*Note: If running on a physical device, ensure you grant Microphone permissions upon first launch.*

## 🛠️ Tech Stack
* **UI:** SwiftUI (Canvas / Path / NavigationStack)
* **Audio:** AVFoundation (AVAudioRecorder, AVAudioPlayer, AVAudioSession)
* **Concurrency:** async/await, Task, @MainActor (Swift 6 Strict Concurrency Ready)
* **Persistence:** FileManager (for .m4a files) and UserDefaults (for user preferences)
