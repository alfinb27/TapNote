//
//  VoiceNoteRowView.swift
//  Tapnote
//
//  Created by Alfin Baby on 12/06/26.
//

import SwiftUI

struct VoiceNoteRowView: View {
    let note: VoiceNote
    let isPlaying: Bool
    let isActive: Bool
    let currentTime: TimeInterval
    
    let onRowTapped: () -> Void
    let onPlayTapped: () -> Void
    let onSeek: (TimeInterval) -> Void
    let onStarTapped: () -> Void
    let onRenameTapped: () -> Void
    let onDeleteTapped: () -> Void
    let onMockFeatureTapped: () -> Void
    
    @State private var isDragging = false
    @State private var localSliderValue: TimeInterval = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onRowTapped) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDateHeader(note.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            HStack {
                HStack {
                    Button(action: onPlayTapped) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                    }
                    
                    if isActive {
                        Slider(
                            value: $localSliderValue,
                            in: 0...(note.duration > 0 ? note.duration : 1),
                            onEditingChanged: { editing in
                                isDragging = editing
                                if !editing {
                                    onSeek(localSliderValue)
                                }
                            }
                        )
                        .accentColor(.black)
                        .onChange(of: currentTime) { oldValue, newValue in
                            if !isDragging { localSliderValue = newValue }
                        }
                    }
                    
                    Text(formatDuration(isActive && isDragging ? localSliderValue : (isActive ? currentTime : note.duration)))
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, isActive ? 12 : 16)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))
                .clipShape(Capsule())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 12) {
                    if !isActive {
                        Button(action: onMockFeatureTapped) { actionButton(icon: "doc.text") }
                    }
                    
                    Menu {
                        Button(action: onStarTapped) {
                            Label(note.isStarred ? "Remove Star" : "Star Recording", systemImage: note.isStarred ? "star.fill" : "star")
                        }
                        Button(action: onRenameTapped) { Label("Rename", systemImage: "pencil") }
                        ShareLink(item: note.url) { Label("Share", systemImage: "square.and.arrow.up") }
                        Button(role: .destructive, action: onDeleteTapped) { Label("Delete", systemImage: "trash") }
                    } label: {
                        actionButton(icon: "ellipsis")
                    }
                }
            }
            Divider().padding(.top, 8)
        }
        .padding(.vertical, 8)
        .onAppear {
            localSliderValue = currentTime
        }
    }
    
    private func actionButton(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundColor(.black)
            .frame(width: 36, height: 36)
            .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
    
    private func formattedDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d • h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let time = duration.isNaN || !duration.isFinite ? 0 : duration
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
