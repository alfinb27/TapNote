//
//  VoiceNotesListViewModel.swift
//  Tapnote
//
//  Created by Alfin Baby on 12/06/26.
//

import Foundation
import Combine

@MainActor
final class VoiceNotesListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedFilter = "All"
    let filters = ["All", "Shared", "Starred"]
    
    let playbackViewModel: PlaybackViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(playbackViewModel: PlaybackViewModel? = nil) {
        self.playbackViewModel = playbackViewModel ?? PlaybackViewModel()
        
        self.playbackViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    var filteredNotes: [VoiceNote] {
        var notes = playbackViewModel.savedNotes
        
        if !searchText.isEmpty {
            notes = notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        if selectedFilter == "Starred" {
            notes = notes.filter { $0.isStarred }
        } else if selectedFilter == "Shared" {
            notes = []
        }
        
        return notes
    }
}
