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
            
            ZStack {
                Image("visualizer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)

                Text("\(minutes):\(String(format: "%02d", seconds))")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Button(action: {
                stopTimer()
                dismiss()
            }) {
                Text("Stop")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.red)
                    )
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.top, 32)
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Sound Sleep")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
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
}

#Preview {
    NavigationView {
        StopView(dismiss: {})
    }
}

