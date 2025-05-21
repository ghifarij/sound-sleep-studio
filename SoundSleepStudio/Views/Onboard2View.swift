//
//  Onboard2View.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 21/05/25.
//

import RealityKit
import SwiftUI

struct Onboard2View: View {
    @State private var entity: Entity?
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
                .foregroundColor(.white)
                .padding(.horizontal)

            // Description
            Text(
                "Allow Sound Sleep to access your heart rate through your Apple Watch. Sound Sleep also requires to access your sleep duration in your Health App"
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.gray)
            .padding(.horizontal, 32)

            Spacer()

            // Continue Button
            Button(action: {
                // Handle navigation or dismiss here
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
            }.padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
                .background(Color.black.edgesIgnoringSafeArea(.all))
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
    Onboard2View()
}
