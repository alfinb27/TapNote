//
//  RecorderViewModel.swift
//  Tapnote
//
//  Created by Alfin Baby on 10/06/26.
//

import Foundation
import Combine

@MainActor
final class RecorderViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var waveformSamples: [Float] = []
    @Published var elapsedTimeString: String = "00:00"
    @Published var isProcessing = false
    @Published var showPermissionAlert = false
    
    private let recorderService = AudioRecorderService()
    private var cancellables = Set<AnyCancellable>()
    private var recordingTimer: Timer?
    private var secondsElapsed = 0
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        recorderService.$isRecording
            .assign(to: \.isRecording, on: self)
            .store(in: &cancellables)
            
        recorderService.$currentSamples
            .assign(to: \.waveformSamples, on: self)
            .store(in: &cancellables)
            
        recorderService.$permissionDenied
            .dropFirst()
            .sink { [weak self] denied in
                if denied {
                    self?.showPermissionAlert = true
                    self?.recorderService.permissionDenied = false
                }
            }
            .store(in: &cancellables)
            
        recorderService.$isRecording
            .dropFirst()
            .sink { [weak self] recording in
                if recording {
                    self?.startTimer()
                } else {
                    self?.stopTimer()
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleRecording() {
        guard !isProcessing else { return }
        isProcessing = true
        
        if isRecording {
            _ = recorderService.stopRecording()
        } else {
            recorderService.startRecording()
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.isProcessing = false
        }
    }
    
    private func startTimer() {
        secondsElapsed = 0
        updateTimeString()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.secondsElapsed += 1
                self?.updateTimeString()
            }
        }
    }
    
    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        secondsElapsed = 0
        updateTimeString()
    }
    
    private func updateTimeString() {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        elapsedTimeString = String(format: "%02d:%02d", minutes, seconds)
    }
}
