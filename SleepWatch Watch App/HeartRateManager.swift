//
//  Heart.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 28/05/25.
//

import HealthKit
import WatchConnectivity

class HeartRateManager: NSObject,
    HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate, WCSessionDelegate
{
    
    

    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    override init() {
        super.init()
        setupWCSession()
    }

    //MARK: - Set up watch seesion
    private func setupWCSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    //MARK: -Set up watch delegate
    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        if message["command"] as? String == "start" {
            startStreaming()
        } else if message["command"] as? String == "stop" {
            stopStreaming()
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
    }
    // MARK: - Authorization
    func requestAuthorization() {
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(
            toShare: typesToShare, read: typesToRead
        ) { success, error in
            if success {
                print("✅ HealthKit fully authorized")
            } else {
                print("❌ Authorization error: \(String(describing: error))")
            }
        }
    }

    // MARK: - Start Workout & Streaming
    func startStreaming() {
        guard session == nil else {
            print("⚠️ Workout already started")
            return
        }

        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(
                healthStore: healthStore, configuration: config)
            session?.delegate = self

            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore, workoutConfiguration: config)
            builder?.delegate = self

            session?.startActivity(with: Date())
        } catch {
            print("❌ Failed to start session: \(error.localizedDescription)")
        }
    }

    // MARK: - Stop Streaming
    func stopStreaming() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { success, error in
            if let error = error {
                print("❌ End collection error: \(error.localizedDescription)")
            } else {
                print("✅ Collection ended")
            }
        }
        session = nil
        builder = nil
    }

    // MARK: - WorkoutSession Delegate
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        if toState == .running {
            builder?.beginCollection(withStart: date) { success, error in
                if let error = error {
                    print(
                        "❌ Begin collection error: \(error.localizedDescription)"
                    )
                } else {
                    print("✅ Collection started")
                }
            }
        }
    }

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        print("❌ Workout session failed: \(error.localizedDescription)")
    }

    // MARK: - WorkoutBuilder Delegate

    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        guard
            collectedTypes.contains(
                HKQuantityType.quantityType(forIdentifier: .heartRate)!)
        else {
            return
        }

        if let statistics = workoutBuilder.statistics(
            for: HKQuantityType.quantityType(forIdentifier: .heartRate)!)
        {
            let unit = HKUnit.count().unitDivided(by: .minute())
            if let value = statistics.mostRecentQuantity()?.doubleValue(
                for: unit)
            {
                WCSession.default.sendMessage(["bpm": value], replyHandler: nil)
                print("❤️ BPM: \(value)")

            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
}
