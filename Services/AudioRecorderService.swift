//
//  AudioRecorderService.swift
//  Tapnote
//
//  Created by Alfin Baby on 10/06/26.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioRecorderService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var currentSamples: [Float] = []
    @Published var permissionDenied = false
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var currentFileURL: URL?
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] allowed in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    if allowed {
                        self.beginActualRecording(session: session)
                    } else {
                        self.permissionDenied = true
                    }
                }
            }
        } else {
            session.requestRecordPermission { [weak self] allowed in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    if allowed {
                        self.beginActualRecording(session: session)
                    } else {
                        self.permissionDenied = true
                    }
                }
            }
        }
    }
    
    private func beginActualRecording(session: AVAudioSession) {
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let fileFormatter = DateFormatter()
            fileFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let fileName = "Recording - \(fileFormatter.string(from: Date())).m4a"
            
            currentFileURL = documentPath.appendingPathComponent(fileName)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            guard let url = currentFileURL else { return }
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            currentSamples = []
            startMeteringTimer()
            
        } catch { }
    }
    
    func stopRecording() -> URL? {
        timer?.invalidate()
        timer = nil
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch { }
        
        isRecording = false
        return currentFileURL
    }
    
    private func startMeteringTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let recorder = self.audioRecorder, recorder.isRecording else { return }
                
                recorder.updateMeters()
                let power = recorder.averagePower(forChannel: 0)
                let normalized = max(0.1, min(1.0, (power + 60) / 60 * 0.9 + 0.1))
                
                if self.currentSamples.count > 40 { self.currentSamples.removeFirst() }
                self.currentSamples.append(normalized)
            }
        }
    }
}
