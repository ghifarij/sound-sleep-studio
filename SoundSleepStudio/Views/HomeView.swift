//
//  AnalyticsView.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 20/05/25.
//

import SwiftUI

struct ECGWaveform: Shape {
    var progress: CGFloat
    var amplitude: CGFloat
    var isFlat: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        if isFlat {
            path.move(to: CGPoint(x: 0, y: height/2))
            path.addLine(to: CGPoint(x: width, y: height/2))
            return path
        }

        let points: [CGPoint] = [
            CGPoint(x: 0.0, y: 0.5),
            CGPoint(x: 0.1, y: 0.48),
            CGPoint(x: 0.15, y: 0.52),
            CGPoint(x: 0.2, y: 0.48),
            CGPoint(x: 0.25, y: 0.5),
            CGPoint(x: 0.3, y: 0.5-amplitude*0.1),
            CGPoint(x: 0.32, y: 0.5+amplitude*0.1),
            CGPoint(x: 0.35, y: 0.5),
            CGPoint(x: 0.4, y: 0.5),
            CGPoint(x: 0.45, y: 0.5-amplitude*0.4),
            CGPoint(x: 0.5, y: 0.5+amplitude*0.9),
            CGPoint(x: 0.55, y: 0.5-amplitude*0.8),
            CGPoint(x: 0.6, y: 0.5),
            CGPoint(x: 0.7, y: 0.5+amplitude*0.2),
            CGPoint(x: 0.8, y: 0.5),
            CGPoint(x: 1.0, y: 0.5)
        ]
        let offset = progress * width
        path.move(to: CGPoint(x: -offset, y: height * points[0].y))
        for pt in points {
            let x = pt.x * width - offset
            let y = pt.y * height
            path.addLine(to: CGPoint(x: x, y: y))
        }
        for pt in points {
            let x = pt.x * width + width - offset
            let y = pt.y * height
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

struct HomeView: View {
    @StateObject private var healthKitService = HealthKitService()
    @State private var progress: CGFloat = 0
    @State private var timer: Timer? = nil

    private var ecgAmplitude: CGFloat {
        healthKitService.currentHeartRate == 0 ? 0 : CGFloat( (Double(healthKitService.currentHeartRate) - 40) / 180 * 1.8 ).clamped(to: 0...1.5)
    }

    private var scrollDuration: Double { 3.0 }
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Sound Sleep")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .accessibilityAddTraits(.isHeader)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)
                        .padding(.horizontal)
                    
                    // Conditional content based on authorization status
                    if healthKitService.initialAuthCheckComplete {
                        if healthKitService.isAuthorized {
                            heartRateSection
                        } else {
                            authorizationSection // This section will now only have the "Open Health App" button
                        }
                    } else {
                        // Show a loading indicator or an empty view while waiting for authorization
                        ProgressView("Checking Health Access...")
                            .padding()
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // checkAuthorizationStatus is called in HealthKitService init
                // and also when scene becomes active
                startECGAnimation()
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    healthKitService.checkAuthorizationStatus()
                }
            }
            .onDisappear {
                stopECGAnimation()
            }
        }
    }
    private var heartRateSection: some View {
        VStack(spacing: 24) {
            ZStack {
                ECGWaveform(progress: progress, amplitude: ecgAmplitude, isFlat: healthKitService.currentHeartRate == 0)
                    .stroke(Color.red, lineWidth: 3)
                    .frame(height: 80)
                    .padding(.horizontal, 8)
                    .clipped()
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(Int(healthKitService.currentHeartRate))")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .accessibilityLabel("Current heart rate")
                Text("BPM")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("beats per minute")
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            Text("Last updated: \(Date().formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel("Last updated \(Date().formatted(date: .abbreviated, time: .shortened))")
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button(action: {
                healthKitService.fetchLatestHeartRate()
                restartECGAnimation()
            }) {
                Text("Refresh")
                    .font(.body)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityHint("Fetch the latest heart rate data and animate the ECG")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
    }
    private func startECGAnimation() {
        stopECGAnimation()
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            let increment = CGFloat(0.016 / scrollDuration)
            progress += increment
            if progress > 1 { progress -= 1 }
        }
    }
    private func stopECGAnimation() {
        timer?.invalidate()
        timer = nil
    }
    private func restartECGAnimation() {
        stopECGAnimation()
        startECGAnimation()
    }
    
    private var authorizationSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .accessibilityHidden(true)
            
            Text("Health Data Access Required")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text("Please grant access to your health data to view your heart rate information.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.body)
                .padding(.horizontal)
            
            Button(action: {
                if let url = URL(string: "x-apple-health://") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Open Health App", systemImage: "arrow.up.right.square") // Changed from "Grant Access"
                    .font(.body)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent) // Changed to prominent for the single primary action
            .controlSize(.large)
            .accessibilityHint("Open the Health app to manage permissions")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    HomeView()
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
