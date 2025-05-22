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
            Color.onboardingBg
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)

                // Cloud moon image
                Image("cloud_moon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 160)

                Spacer()
                    .frame(height: 40)

                // Welcome text
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.textPrimary)
                    
                    Text("Sound Sleep")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.textPrimary)
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

                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .background(Color.brandPurple)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, bottomInset > 0 ? bottomInset + 16 : 32)
            }
        }
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView { }
            .previewDevice("iPhone 14 Pro")
            .preferredColorScheme(.dark)
    }
}
#endif
