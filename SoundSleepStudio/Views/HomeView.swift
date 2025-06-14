//
//  AnalyticsView.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 20/05/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State private var isPreviewPlaying = false
    @State private var foregroundSelectedSound = "Sound 1"
    @State private var backgroundSelectedSound = "Sound 2"
    @State private var foregroundVolume = 0.5
    @State private var backgroundVolume = 0.5
    @State private var navigateToStopView = false
    @State private var avPlayer1 = AudioService()
    @State private var avPlayer2 = AudioService()
    @StateObject private var bpmManager = HeartRateController()

    let foregroundSounds = ["Sound 1", "Sound 2", "Sound 3"]
    let backgroundSounds = ["Sound 1", "Sound 2", "Sound 3"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Preview Sound Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Preview Sound")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle("", isOn: $isPreviewPlaying)
                                .labelsHidden()
                                .tint(Color.brandPurple)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Foreground Sound Section
                    VStack(alignment: .leading, spacing: 12) {
                        // Sound Selection Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Foreground Sound")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Menu {
                                    ForEach(foregroundSounds, id: \.self) { sound in
                                        Button(sound) {
                                            foregroundSelectedSound = sound
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(foregroundSelectedSound)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)

                        // Volume Control Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Volume")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(Color.brandPurple)
                                Slider(value: $foregroundVolume, in: 0...1)
                                    .tint(Color.brandPurple)
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(Color.brandPurple)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal)

                    // Background Sound Section
                    VStack(alignment: .leading, spacing: 12) {
                        // Sound Selection Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Background Sound")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Menu {
                                    ForEach(backgroundSounds, id: \.self) { sound in
                                        Button(sound) {
                                            backgroundSelectedSound = sound
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(backgroundSelectedSound)
                                            .foregroundColor(.secondary)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)

                        // Volume Control Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Volume")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(Color.brandPurple)
                                Slider(value: $backgroundVolume, in: 0...1)
                                    .tint(Color.brandPurple)
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(Color.brandPurple)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal)

                    // Start Button
                    Button(action: {
                        startSleepSession()
                    }) {
                        Text("Start")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 14, style: .continuous
                                )
                                .fill(Color.brandPurple)
                            )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Sound Sleep")
            .navigationDestination(isPresented: $navigateToStopView) {
                StopView(
                    bpmManager: bpmManager,
                    avPlayer1: avPlayer1,
                    avPlayer2: avPlayer2,
                    dismiss: {
                        navigateToStopView = false
                    }
                )
            }
        }
        .onAppear {
            setupView()
        }
        .onDisappear {
            cleanup()
        }
        .onChange(of: isPreviewPlaying) { _, isPlaying in
            handlePreviewToggle(isPlaying: isPlaying)
        }
        .onChange(of: foregroundVolume) { _, newValue in
            avPlayer1.setVolume(Float(newValue))
        }
        .onChange(of: backgroundVolume) { _, newValue in
            avPlayer2.setVolume(Float(newValue))
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        bpmManager.setContext(context)
        
        // Pre-load audio files for better performance
        avPlayer1.load(trackName: "foreground")
        avPlayer2.load(trackName: "background")
    }
    
    private func cleanup() {
        if isPreviewPlaying {
            isPreviewPlaying = false
            avPlayer1.stop()
            avPlayer2.stop()
        }
    }
    
    private func handlePreviewToggle(isPlaying: Bool) {
        if isPlaying {
            // Start preview with current volumes
            avPlayer1.setVolume(Float(foregroundVolume))
            avPlayer2.setVolume(Float(backgroundVolume))
            
            avPlayer1.play()
            avPlayer2.play()
        } else {
            // Stop preview
            avPlayer1.stop()
            avPlayer2.stop()
        }
    }
    
    private func startSleepSession() {
        // Stop preview if playing
        if isPreviewPlaying {
            isPreviewPlaying = false
            avPlayer1.stop()
            avPlayer2.stop()
        }
        
        // Set volumes
        avPlayer1.setVolume(Float(foregroundVolume))
        avPlayer2.setVolume(Float(backgroundVolume))
        
        // Start sleep session
        navigateToStopView = true
        avPlayer1.playWithTimedStop()
        avPlayer2.playWithTimedStop()
        bpmManager.startHeartRate()
    }
}

#Preview {
    HomeView()
}
