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
    @State private var foregroundSelectedSound = "Piano"
    @State private var backgroundSelectedSound = "Rain"
    @State private var foregroundVolume = 0.5
    @State private var backgroundVolume = 0.5
    @State private var navigateToStopView = false
    @State public var avPlayer1 = AudioService()
    @State public var avPlayer2 = AudioService()
    @StateObject public var bpmManager = HeartRateController()

    let foregroundSounds = ["Piano", "Pads", "Breathing Voice"]
    let backgroundSounds = ["Rain", "Waves", "Forest"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Sound Picker Row
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

                        Divider()

                        // Volume Slider Row
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(Color.brandPurple)
                                Slider(value: $foregroundVolume, in: 0...1)
                                    .accentColor(Color.brandPurple)
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(Color.brandPurple)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .shadow(
                        color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Background Sound Section
                    VStack(alignment: .leading, spacing: 12) {
                        // Sound Picker Row
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

                        Divider()

                        // Volume Slider Row
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(Color.brandPurple)
                                Slider(value: $backgroundVolume, in: 0...1)
                                    .accentColor(Color.brandPurple)
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(Color.brandPurple)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .shadow(
                        color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2
                    )
                    .padding(.horizontal)

                    // Start Button
                    Button(action: {
                        navigateToStopView = true
                        avPlayer1.load(trackName: "sample1")
                        avPlayer1.play()
                        avPlayer2.load(trackName: "sample2")
                        avPlayer2.play()
                        bpmManager.startHeartRate()
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
                .onAppear{
                    bpmManager.setContext(context)
                }
            }
            .navigationTitle("Sound Sleep")
            .navigationDestination(isPresented: $navigateToStopView) {
                StopView(bpmManager: bpmManager, avPlayer1: avPlayer1, avPlayer2: avPlayer2, dismiss: { navigateToStopView = false })
            }
        }
    }
}

#Preview {
    HomeView()
}
