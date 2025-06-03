//
//  OnboardingView.swift
//  SoundSleepStudio
//
//  Created by Kelvin on 21/05/25.
//

import RealityKit
import SwiftUI
import HealthKit

struct SecondOnboardingView: View {
    @State private var entity: Entity?
    @State private var isRequestingPermission = false
    @State private var errorMessage: String? = nil
//    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    
    @Binding var currentScreen: SoundSleepStudioApp.AppScreen
    
    // Use the shared HealthKitService for centralized permission handling
    @StateObject private var healthKitService = HealthKitService()
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()

            // Apple Watch Image
            RealityView { content in
                do {
                    let loadedEntity = try await Entity(named: "AppleWatch")
                    loadedEntity.setScale([0.3, 0.3, 0.3], relativeTo: nil)
                    loadedEntity.position = [0, -2, -3]

                    self.entity = loadedEntity
                    content.add(loadedEntity)

                    let light = DirectionalLight()
                    content.add(light)

                    startRotation()
                } catch {
                    print("❌ Failed to load model:", error)
                }
            }
            .frame(height: 300)

            // Title
            Text("Wear Your Apple Watch")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)

            // Description
            Text(
                "Allow Sound Sleep to access your heart rate through your Apple Watch"
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.horizontal, 32)
            
            // Show error message if any
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            // Continue Button - using HealthKitService
            Button(action: {
                requestHealthPermissions()
            }) {
                if isRequestingPermission {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                } else {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
            }
            .background(Color.brandPurple)
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .disabled(isRequestingPermission)
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
    
    // Request HealthKit permissions using our HealthKitService
    private func requestHealthPermissions() {
        isRequestingPermission = true
        errorMessage = nil
        
        // Use HealthKitService to request permissions
        healthKitService.requestHealthKitPermission { success, error in
            DispatchQueue.main.async {
                isRequestingPermission = false
                
                if !success, let error = error {
                    errorMessage = "Health permission error: \(error.localizedDescription)"
                    print("Health permission error: \(error.localizedDescription)")
                } else if success {
                    print("Health permissions granted successfully")
                }
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    hasCompletedOnboarding = true
//                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    currentScreen = .main
                                }
            }
        }
    }
    
    // MARK: - Rotate the model continuously
    func startRotation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            guard let entity = self.entity else { return }
            let angle = Float(0.01)
            let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
            entity.transform.rotation *= rotation
        }
    }
}

#Preview {
    SecondOnboardingView(currentScreen: .constant(.onboarding2))
}
