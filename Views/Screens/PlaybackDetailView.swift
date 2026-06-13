//
//  PlaybackDetailView .swift
//  Tapnote
//
//  Created by Alfin Baby on 12/06/26.
//


import SwiftUI

struct PlaybackDetailView: View {
    let note: VoiceNote
    @ObservedObject var viewModel: PlaybackViewModel
    
    @State private var isDraggingSlider = false
    @State private var sliderValue: TimeInterval = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 120, weight: .ultraLight))
                .foregroundColor(Color.blue.opacity(0.8))
                .shadow(color: .blue.opacity(0.3), radius: 20, y: 10)
            
            VStack(spacing: 8) {
                Text(note.title)
                    .font(.system(.title2, design: .serif))
                    .bold()
                
                Text(note.createdAt, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 10) {
                Slider(
                    value: $sliderValue,
                    in: 0...(viewModel.duration > 0 ? viewModel.duration : 1),
                    onEditingChanged: { editing in
                        isDraggingSlider = editing
                        if !editing {
                            viewModel.seek(to: sliderValue)
                        }
                    }
                )
                .accentColor(.blue)
                
                HStack {
                    Text(formatTime(isDraggingSlider ? sliderValue : viewModel.currentTime))
                    Spacer()
                    Text("-" + formatTime(viewModel.duration - (isDraggingSlider ? sliderValue : viewModel.currentTime)))
                }
                .font(.caption.monospacedDigit())
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
            .onChange(of: viewModel.currentTime) { oldValue, newValue in
                if !isDraggingSlider {
                    sliderValue = newValue
                }
            }
            
            HStack(spacing: 40) {
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    viewModel.skipBackward()
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    viewModel.togglePlayback(for: note)
                }) {
                    Image(systemName: viewModel.currentlyPlayingID == note.id && viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.black)
                }
                
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    viewModel.skipForward()
                }) {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.currentlyPlayingID != note.id {
                viewModel.togglePlayback(for: note)
            }
        }
        .onDisappear {
            viewModel.pause()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && time.isFinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
