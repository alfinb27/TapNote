//
//  SiriWaveformView.swift
//  Tapnote
//
//  Created by Alfin Baby on 11/06/26.
//

import SwiftUI

struct SiriWaveformView: View {
    var samples: [Float]
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    private let frequency: CGFloat = 1.5
    
    private var dynamicAmplitude: CGFloat {
        let rawSample = CGFloat(samples.last ?? 0.1)
        return rawSample <= 0.11 ? 5 : (rawSample * 80)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.13, green: 0.27, blue: 0.18).opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
            
            Circle()
                .fill(Color.clear)
                .frame(width: 250, height: 250)
                .background(
                    ZStack {
                        AdvancedWaveShape(amplitude: dynamicAmplitude, frequency: frequency, phase: phase1)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0.13, green: 0.27, blue: 0.18), .green]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(0.8)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: dynamicAmplitude)
                        
                        AdvancedWaveShape(amplitude: max(5, dynamicAmplitude - 15), frequency: frequency + 0.5, phase: phase2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, Color(red: 0.13, green: 0.27, blue: 0.18)]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .opacity(0.5)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dynamicAmplitude)
                    }
                )
                .clipShape(Circle())
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase1 -= .pi * 2
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                phase2 -= .pi * 2
            }
        }
    }
}
