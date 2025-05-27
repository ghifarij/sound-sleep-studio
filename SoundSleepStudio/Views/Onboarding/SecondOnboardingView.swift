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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Create a health store instance here
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
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
                "Allow Sound Sleep to access your heart rate through your Apple Watch. Sound Sleep also requires to access your sleep duration in your Health App"
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.horizontal, 32)

            Spacer()

            // Continue Button - now with proper health permission request
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
    
    // Request HealthKit permissions
    private func requestHealthPermissions() {
        isRequestingPermission = true
        
        // Request health permissions
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                isRequestingPermission = false
                
                if success {
                    print("Health permissions granted")
                } else if let error = error {
                    print("Health permission error: \(error.localizedDescription)")
                }
                
                // Regardless of permission result, mark onboarding as complete
                // This is important - we continue even if they deny permission
                hasCompletedOnboarding = true
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
    SecondOnboardingView()
}
