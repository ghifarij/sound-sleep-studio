//
//  SoundSleepStudioApp.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 19/05/25.
//

import SwiftUI

@main
struct SoundSleepStudioApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView {
                // Handle Continue tapped here:
                // e.g. set @AppStorage flag or navigate to your main UI
                print("Continue tapped")
            }
            // Force dark mode to validate design
            .environment(\.colorScheme, .dark)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            BabyRhythmMonitorView()
                .tabItem {
                    Label("Monitor", systemImage: "waveform.path.ecg")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear.circle.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}

// Baby Rhythm Monitor View
struct BabyRhythmMonitorView: View {
    @State private var isMonitoring = false
    @State private var brpm: Double = 0.0
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background dims when monitoring
                Color(.systemBackground)
                    .opacity(isMonitoring ? 0.2 : 1)
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("Baby Rhythm Monitor")
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                    // Waveform placeholder
                    WaveformView(brpm: brpm)
                        .frame(height: 200)
                        .padding(.horizontal)

                    // Display current breaths per minute
                    Text(String(format: "%.0f BrPM", brpm))
                        .font(.title)
                        .monospacedDigit()

                    // Start/Stop button
                    Button(action: toggleMonitoring) {
                        Text(isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isMonitoring ? Color.red : Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .blur(radius: isMonitoring ? 2 : 0)
            }
            .navigationTitle("Monitor")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Breathing Pause Detected"),
                message: Text("No breath detected for 10 seconds."),
                dismissButton: .default(Text("OK")))
        }
    }

    private func toggleMonitoring() {
        isMonitoring.toggle()
        if isMonitoring {
            brpm = 28 // placeholder; real data from audio pipeline
            // start audio and detection
        } else {
            // stop audio and detection
        }
    }
}

// Placeholder waveform view
struct WaveformView: View {
    var brpm: Double

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let width = size.width
                    let height = size.height
                    let midY = height / 2
                    let amplitude: CGFloat = 30
                    let frequency = brpm / 60
                    
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: midY))
                    for x in stride(from: 0, to: width, by: 1) {
                        let relativeX = x / width
                        let angle = relativeX * Double.pi * 2.0 * frequency
                        let y = midY + sin(angle + timeline.date.timeIntervalSince1970) * amplitude
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    context.stroke(path, with: .color(.green), lineWidth: 2)
                }
            }
        }
    }
}
