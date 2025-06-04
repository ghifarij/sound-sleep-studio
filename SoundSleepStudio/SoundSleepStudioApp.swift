//
//  SoundSleepStudioApp.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 19/05/25.
//

import SwiftUI
import BackgroundTasks
import HealthKit
import SwiftData

@main
struct SoundSleepStudioApp: App {
//    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    @State private var currentScreen: AppScreen = .onboarding
    
    enum AppScreen {
        case onboarding
        case onboarding2
        case main
    }
    
    init() {
        // Register for background processing
        registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
//                if hasCompletedOnboarding {
//                    MainTabView()
//                } else {
                    
                    switch currentScreen {
                    case .onboarding:
                        OnboardingView {
                            currentScreen = .onboarding2
                        }
                    case .onboarding2:
//                        SecondOnboardingView()
                        SecondOnboardingView(currentScreen: $currentScreen)
                    case .main:
                        MainTabView()
                    }
//                }
            }
        }
        .modelContainer(for: [HeartRateSession.self, BpmRecord.self])
        
    }
    
    private func registerBackgroundTasks() {
        // Register for HealthKit background processing
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.soundsleepstudio.healthkit.refresh", using: nil) { task in
            // This can be used for periodic health data refreshes if needed
            self.handleHealthKitBackgroundRefresh(task: task as! BGProcessingTask)
        }
    }
    
    private func handleHealthKitBackgroundRefresh(task: BGProcessingTask) {
        // Schedule the next background refresh
        scheduleBackgroundHealthKitRefresh()
        
        // Set up an expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform the health data refresh operation
        // In real usage, this would interact with your HealthKitService
        // For now, we'll just mark the task as completed
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleBackgroundHealthKitRefresh() {
        let request = BGProcessingTaskRequest(identifier: "com.soundsleepstudio.healthkit.refresh")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        // Schedule between 1 and 2 hours from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background refresh: \(error.localizedDescription)")
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
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(1)
        
        }
        .accentColor(Color.brandPurple)
    }
}
