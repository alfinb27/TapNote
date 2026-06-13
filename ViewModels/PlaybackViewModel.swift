//
//  PlaybackViewModel.swift
//  Tapnote
//
//  Created by Alfin Baby on 10/06/26.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

@MainActor
final class PlaybackViewModel: ObservableObject {
    @Published var savedNotes: [VoiceNote] = []
    @Published var isPlaying = false
    @Published var currentlyPlayingID: UUID?
    @Published var currentTime: TimeInterval = 0.0
    @Published var duration: TimeInterval = 0.0
    @Published var starredNoteNames: Set<String> = []
    
    private let playerService = AudioPlayerService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        if let savedStars = UserDefaults.standard.array(forKey: "StarredNotes") as? [String] {
            starredNoteNames = Set(savedStars)
        }
        setupBindings()
        fetchRecordings()
    }
    
    private func setupBindings() {
        playerService.$isPlaying.sink { [weak self] playing in
            self?.isPlaying = playing
            if !playing { self?.currentlyPlayingID = nil }
        }.store(in: &cancellables)
        
        playerService.$currentTime.assign(to: \.currentTime, on: self).store(in: &cancellables)
        playerService.$duration.assign(to: \.duration, on: self).store(in: &cancellables)
    }
    
    func fetchRecordings() {
        Task {
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentPath, includingPropertiesForKeys: [.creationDateKey])
                let m4aFiles = directoryContents.filter { $0.pathExtension == "m4a" }
                var fetchedNotes: [VoiceNote] = []
                
                for url in m4aFiles {
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let creationDate = attributes?[.creationDate] as? Date ?? Date()
                    let fileName = url.lastPathComponent
                    let audioAsset = AVURLAsset(url: url)
                    var audioDuration: TimeInterval = 0
                    
                    if #available(iOS 16.0, *) {
                        if let duration = try? await audioAsset.load(.duration) {
                            audioDuration = CMTimeGetSeconds(duration)
                        }
                    } else {
                        audioDuration = CMTimeGetSeconds(audioAsset.duration)
                    }
                    
                    let note = VoiceNote(
                        id: UUID(),
                        url: url,
                        createdAt: creationDate,
                        title: url.deletingPathExtension().lastPathComponent,
                        duration: audioDuration.isNaN ? 0 : audioDuration,
                        isStarred: starredNoteNames.contains(fileName)
                    )
                    fetchedNotes.append(note)
                }
                
                self.savedNotes = fetchedNotes.sorted(by: { $0.createdAt > $1.createdAt })
            } catch { }
        }
    }
    
    // MARK: - Actions
    
    func toggleStar(for note: VoiceNote) {
        let fileName = note.url.lastPathComponent
        if starredNoteNames.contains(fileName) {
            starredNoteNames.remove(fileName)
        } else {
            starredNoteNames.insert(fileName)
        }
        UserDefaults.standard.set(Array(starredNoteNames), forKey: "StarredNotes")
        
        if let index = savedNotes.firstIndex(where: { $0.id == note.id }) {
            savedNotes[index].isStarred.toggle()
        }
    }
    
    func delete(note: VoiceNote) {
        if currentlyPlayingID == note.id {
            playerService.pause()
            currentlyPlayingID = nil
        }
        
        do {
            if FileManager.default.fileExists(atPath: note.url.path) {
                try FileManager.default.removeItem(at: note.url)
            }
            let fileName = note.url.lastPathComponent
            starredNoteNames.remove(fileName)
            UserDefaults.standard.set(Array(starredNoteNames), forKey: "StarredNotes")
            fetchRecordings()
        } catch { }
    }
    
    func togglePlayback(for note: VoiceNote) {
        if currentlyPlayingID == note.id && isPlaying {
            playerService.pause()
            currentlyPlayingID = nil
        } else {
            playerService.loadAudio(url: note.url)
            playerService.play()
            currentlyPlayingID = note.id
        }
    }
    
    func rename(note: VoiceNote, to newName: String) {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let directory = note.url.deletingLastPathComponent()
        let newURL = directory.appendingPathComponent("\(newName).m4a")
        
        do {
            try FileManager.default.moveItem(at: note.url, to: newURL)
            fetchRecordings()
        } catch { }
    }
    
    func seek(to time: TimeInterval) {
        playerService.seek(to: time)
    }
    
    func skipForward() {
        let newTime = min(currentTime + 10.0, duration)
        seek(to: newTime)
    }
    
    func skipBackward() {
        let newTime = max(currentTime - 10.0, 0.0)
        seek(to: newTime)
    }
    
    func pause() {
        playerService.pause()
        currentlyPlayingID = nil
    }
}
