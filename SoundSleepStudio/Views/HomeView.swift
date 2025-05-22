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
            path.addLine(to: CGPoint(x: widt// ... existing code ...
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
                    
                    // Always show heart rate section
                    heartRateSection
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startECGAnimation()
                // Force refresh heart rate data when view appears
                healthKitService.refresh()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .active:
                    // When app becomes active, refresh heart rate data
                    healthKitService.refresh()
                    if ecgTimer == nil {
                        startECGAnimation()
                    }
                case .inactive:
                    // No action needed
                    break
                case .background:
                    // Stop ECG animation in background
                    stopECGAnimation()
                @unknown default:
                    break
                }
            }
            .onDisappear {
                // Don't stop ECG animation when navigating within app
            }
        }
    }
// ... existing code ...h, y: height/2))
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
    @StateObject private var healthKitService: HealthKitService
    @State private var progress: CGFloat = 0
    @State private var ecgTimer: Timer? = nil
    // --- Timer & Sound Picker State ---
    @State private var countDownTimer: Timer? = nil
    @State private var selectedSound: String = "Wave"
    @State private var isTimerRunning: Bool = false
    @State private var remainingSeconds: Int = 15 * 60 // 15 minutes default
    @State private var userSetSeconds: Int = 15 * 60 // For future: allow user to set
    let soundOptions = ["Wave", "Forest", "Night", "Rain"]
    // -------------------------------

    // Initialize with default HealthKitService for real device
    init(healthKitService: HealthKitService = HealthKitService()) {
        _healthKitService = StateObject(wrappedValue: healthKitService)
    }

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
                    
                    // Always show heart rate section
                    heartRateSection
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startECGAnimation()
                // Force refresh heart rate data when view appears
                healthKitService.refresh()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .active:
                    // When app becomes active, refresh heart rate data
                    healthKitService.refresh()
                    if ecgTimer == nil {
                        startECGAnimation()
                    }
                case .inactive:
                    // No action needed
                    break
                case .background:
                    // Stop ECG animation in background
                    stopECGAnimation()
                @unknown default:
                    break
                }
            }
            .onDisappear {
                // Don't stop ECG animation when navigating within app
            }
        }
    }
    
    private var heartRateSection: some View {
        VStack(spacing: 24) {
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
            
            ZStack {
                ECGWaveform(progress: progress, amplitude: ecgAmplitude, isFlat: healthKitService.currentHeartRate == 0)
                    .stroke(Color.red, lineWidth: 3)
                    .frame(height: 180)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 32)
                    .clipped()
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
            
            // --- Timer & Sound Picker UI ---
            VStack(spacing: 16) {
                // Timer Display
                Text(timerString(from: remainingSeconds))
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Timer: \(timerString(from: remainingSeconds))")
                // Sound Picker
                Picker("Sound", selection: $selectedSound) {
                    ForEach(soundOptions, id: \ .self) { sound in
                        Text(sound)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .disabled(isTimerRunning)
                .accessibilityLabel("Choose sound")
                // Start Button
                Button(action: {
                    startTimer()
                }) {
                    Text(isTimerRunning ? "Running..." : "Start")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isTimerRunning ? Color(.systemGray4) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isTimerRunning)
                .accessibilityLabel(isTimerRunning ? "Timer running" : "Start timer")
            }
            .padding(.top, 8)
            // --- End Timer & Sound Picker UI ---
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
        ecgTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            let increment = CGFloat(0.016 / self.scrollDuration)
            self.progress += increment
            if self.progress > 1 { self.progress -= 1 }
        }
    }
    private func stopECGAnimation() {
        ecgTimer?.invalidate()
        ecgTimer = nil
    }
    private func restartECGAnimation() {
        stopECGAnimation()
        startECGAnimation()
    }
    // --- Timer Helper Functions ---
    private func timerString(from seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%02d : %02d : %02d", h, m, s)
        } else {
            return String(format: "%02d : %02d", m, s)
        }
    }
    private func startTimer() {
        remainingSeconds = userSetSeconds // Always reset to default (15 min)
        isTimerRunning = true
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.countDownTimer?.invalidate()
                self.countDownTimer = nil
                self.isTimerRunning = false
            }
        }
    }
}


#Preview("Default") {
    HomeView()
}

#Preview("60 BPM") {
    HomeView(healthKitService: .preview60BPM)
}

#Preview("80 BPM") {
    HomeView(healthKitService: .preview80BPM)
}

#Preview("100 BPM") {
    HomeView(healthKitService: .preview100BPM)
}

#Preview("120 BPM") {
    HomeView(healthKitService: .preview120BPM)
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
