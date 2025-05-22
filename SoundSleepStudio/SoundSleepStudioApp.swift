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
                // Handle Continue tap here:
                // e.g. set @AppStorage flag or navigate to your main UI
                print("Continue tapped")
            }
            // Force dark mode to validate design
            .environment(\.colorScheme, .dark)
        }
    }
}
