//
//  OnboardingView.swift
//  SoundSleepStudio
//
//  Created by Kelvin on 21/05/25.
//

// Sources/Views/Onboarding/OnboardingView.swift

import SwiftUI
import UIKit

extension UIApplication {
    /// The current active key window, using UIWindowScene.windows (iOS 15+)
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

struct OnboardingView: View {
    var onContinue: () -> Void = {}

    /// Safely grab bottom safe-area inset via our new helper
    private var bottomInset: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }

    var body: some View {
        ZStack {
            // Replace custom background color with system color
            Color(.systemBackground)
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)

                // Cloud moon image
                Image("Cloud_Moon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 160)

                Spacer()
                    .frame(height: 40)

                // Welcome text
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.primary) // Ensure using .primary
                    
                    Text("Sound Sleep")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary) // Ensure using .primary
                }
                .multilineTextAlignment(.center)

                Spacer()
                    .frame(height: 50)

                // Feature rows
                VStack(spacing: 32) {
                    FeatureRow(
                        systemIconName: "music.note",
                        title: "Smart Audio",
                        description: "Smart audio that syncs seamlessly with your heartbeat"
                    )

                    FeatureRow(
                        systemIconName: "bed.double",
                        title: "Your Sleeping Company",
                        description: "Gradually slowing the tempo to lull you into sleep"
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                // Continue button - keep the brand purple color
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white) // This is fine as button text on colored background
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .background(Color.brandPurple) // Keep this as is
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, bottomInset > 0 ? bottomInset + 16 : 32)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

// Remove the duplicate FeatureRow struct declaration below
// struct FeatureRow: View { ... }
