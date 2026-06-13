//
//  ActiveRecordingOverlay.swift
//  Tapnote
//
//  Created by Alfin Baby on 12/06/26.
//

import SwiftUI

struct ActiveRecordingOverlay: View {
    @ObservedObject var viewModel: RecorderViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chevron.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)
                .frame(width: 36, height: 36)
                .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding(.top, 16)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.systemGray6))
                
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer()
                        AdvancedWaveShape(amplitude: dynamicAmplitude, frequency: 1.5, phase: 0)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.5), Color.blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: geo.size.height * 0.5)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                    Text(viewModel.elapsedTimeString)
                        .font(.system(.title3, design: .monospaced).bold())
                }
                .foregroundColor(.black)
            }
            .frame(height: 80)
            .padding(.horizontal, 24)
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                viewModel.toggleRecording()
            }) {
                HStack {
                    Text("Done")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.black)
                .cornerRadius(28)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
        }
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 20, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private var dynamicAmplitude: CGFloat {
        let rawSample = CGFloat(viewModel.waveformSamples.last ?? 0.1)
        return rawSample <= 0.11 ? 2 : (rawSample * 40)
    }
}
