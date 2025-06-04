//
//  HomeStopView.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 01/06/25.
//

import SwiftUI

struct StopView: View {
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var timer: Timer? = nil
    @State public var bpmManager: HeartRateController
    @State public var avPlayer1: AudioService
    @State public var avPlayer2: AudioService
    @State private var player1Stopped = false
    @State private var player2Stopped = false
    var dismiss: () -> Void
    
    var body: some View {
            VStack(spacing: 24) {
                Text("You are set to sleep now")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Push your phone away, close your eyes, and feel the music. Your mind deserves rest, and your body knows how to relax.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                
                BreathingAnimationView()
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Playing Sound")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        stopAndDismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .foregroundStyle(Color.brandPurple)
                }
            }
            .interactiveDismissDisabled() // Prevent swipe to dismiss
            .onAppear {
                startTimer()
                setupCompletionHandlers()
            }
            .onDisappear {
                stopTimer()
            }
        }
    
    private func setupCompletionHandlers() {
            avPlayer1.onPlaybackComplete = {
                player1Stopped = true
                checkIfBothPlayersStopped()
            }
            
            avPlayer2.onPlaybackComplete = {
                player2Stopped = true
                checkIfBothPlayersStopped()
            }
        }
        
    private func checkIfBothPlayersStopped() {
        if player1Stopped && player2Stopped {
            DispatchQueue.main.async {
                stopAndDismiss()
            }
        }
    }
    
    private func startTimer() {
        // Reset the timer values when starting
        minutes = 0
        seconds = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if seconds < 59 {
                seconds += 1
            } else {
                minutes += 1
                seconds = 0
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopAndDismiss() {
        stopTimer()
        avPlayer1.stop()
        avPlayer2.stop()
        bpmManager.stopHeartRate()
        dismiss()
    }
}


struct BreathingAnimationView: View {
    @State private var isBreathingIn = false
    @State private var innerScale: CGFloat = 0.8
    @State private var outerScale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    
    let breathDuration: Double = 4.0
    
    var body: some View {
        ZStack {
            // Outer breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.brandPurple.opacity(0.5),
                            Color.brandPurple.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .scaleEffect(outerScale)
                .opacity(opacity)
            
            // Inner breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.brandPurple.opacity(0.3),
                            Color.brandPurple.opacity(0.1)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .scaleEffect(innerScale)
                .opacity(opacity)
        }
        .padding()
        .frame(width: 300, height: 300)
        .onAppear {
            withAnimation(
                .easeInOut(duration: breathDuration)
                .repeatForever(autoreverses: true)
            ) {
                innerScale = 1.2
                outerScale = 1.4
                opacity = 0.4
            }
        }
    }
}
