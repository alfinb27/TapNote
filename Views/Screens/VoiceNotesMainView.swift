//
//  VoiceNotesMainView.swift
//  Tapnote
//
//  Created by Alfin Baby on 12/06/26.
//

import SwiftUI

@MainActor
struct VoiceNotesMainView: View {
    @StateObject private var listViewModel = VoiceNotesListViewModel()
    @StateObject private var recorderViewModel = RecorderViewModel()
    
    @State private var noteToRename: VoiceNote?
    @State private var newFileName: String = ""
    @State private var showComingSoon = false
    @State private var selectedNoteForDetail: VoiceNote?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        searchAndFilterSection
                        
                        LazyVStack(spacing: 0) {
                            if listViewModel.filteredNotes.isEmpty {
                                Text("No recordings found.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 60)
                            } else {
                                ForEach(listViewModel.filteredNotes) { note in
                                    VoiceNoteRowView(
                                        note: note,
                                        isPlaying: listViewModel.playbackViewModel.isPlaying && listViewModel.playbackViewModel.currentlyPlayingID == note.id,
                                        isActive: listViewModel.playbackViewModel.currentlyPlayingID == note.id,
                                        currentTime: listViewModel.playbackViewModel.currentTime,
                                        onRowTapped: {
                                            selectedNoteForDetail = note
                                        },
                                        onPlayTapped: {
                                            listViewModel.playbackViewModel.togglePlayback(for: note)
                                        },
                                        onSeek: { time in
                                            listViewModel.playbackViewModel.seek(to: time)
                                        },
                                        onStarTapped: {
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            listViewModel.playbackViewModel.toggleStar(for: note)
                                        },
                                        onRenameTapped: {
                                            noteToRename = note
                                            newFileName = note.title
                                        },
                                        onDeleteTapped: {
                                            listViewModel.playbackViewModel.delete(note: note)
                                        },
                                        onMockFeatureTapped: {
                                            showComingSoon = true
                                        }
                                    )
                                }
                            }
                        }
                        
                        Spacer().frame(height: recorderViewModel.isRecording ? 140 : 40)
                    }
                    .padding(.horizontal)
                }
                
                if recorderViewModel.isRecording {
                    ActiveRecordingOverlay(viewModel: recorderViewModel)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                } else {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            recorderViewModel.toggleRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                                .frame(width: 88, height: 88)
                                .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.1), radius: 20, y: 10))
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 40)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .onAppear { listViewModel.playbackViewModel.fetchRecordings() }
            .onChange(of: recorderViewModel.isRecording) { oldValue, newValue in
                if !newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            listViewModel.playbackViewModel.fetchRecordings()
                        }
                    }
                }
            }
            .alert("Feature in Development", isPresented: $showComingSoon) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("AI Transcription and advanced settings will be available in V2.")
            }
            .alert("Rename Recording", isPresented: Binding<Bool>(
                get: { noteToRename != nil },
                set: { if !$0 { noteToRename = nil } }
            )) {
                TextField("New name", text: $newFileName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if let note = noteToRename {
                        listViewModel.playbackViewModel.rename(note: note, to: newFileName)
                    }
                    noteToRename = nil
                }
            }
            .alert("Microphone Access Required", isPresented: $recorderViewModel.showPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            } message: {
                Text("Tapnote needs microphone access to record your voice notes. Please enable it in Settings.")
            }
            .navigationDestination(item: $selectedNoteForDetail) { note in
                PlaybackDetailView(note: note, viewModel: listViewModel.playbackViewModel)
            }
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        HStack {
            Text("Voice Notes")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: { recorderViewModel.toggleRecording() }) { Image(systemName: "plus") }
                Button(action: { showComingSoon = true }) { Image(systemName: "calendar") }
                Button(action: { showComingSoon = true }) { Image(systemName: "gearshape") }
            }
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
            .overlay(Capsule().stroke(Color.gray.opacity(0.15), lineWidth: 1))
        }
        .padding(.top, 10)
    }
    
    private var searchAndFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
                
                TextField("Search", text: $listViewModel.searchText)
                    .font(.system(size: 16))
                
                Button(action: { showComingSoon = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("Ask AI")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
            
            HStack(spacing: 12) {
                ForEach(listViewModel.filters, id: \.self) { filter in
                    Text(filter)
                        .font(.system(size: 15, weight: listViewModel.selectedFilter == filter ? .semibold : .medium))
                        .foregroundColor(listViewModel.selectedFilter == filter ? .black : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(listViewModel.selectedFilter == filter ? Color(UIColor.systemGray5) : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            withAnimation(.snappy) { listViewModel.selectedFilter = filter }
                        }
                }
            }
        }
    }
}
