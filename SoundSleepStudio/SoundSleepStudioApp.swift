//
//  SoundSleepStudioApp.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 19/05/25.
//

import SwiftUI
import SwiftData

@main
struct SoundSleepStudioApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                ContentView()
                    .tabItem {
                        Label("Settings", systemImage: "gear.circle.fill")
                    }
                    .tag(1)
            }
            .accentColor(.blue)
        }
    }
}
