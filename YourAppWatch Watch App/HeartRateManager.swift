//
//  HeartRateManager.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 28/05/25.
//


import HealthKit


class HeartRateManager: NSObject, ObservableObject, HKLiveWorkoutBuilderDelegate {
    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var bpm: Double = 0.0

    override init() {
        super.init()
        requestAuthorization()
    }

    func requestAuthorization() {
        let types: Set = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        healthStore.requestAuthorization(toShare: nil, read: types) { success, error in
            if success {
                print("✅ HealthKit authorized")
            } else {
                print("❌ Authorization error: \(String(describing: error))")
            }
        }
    }

    func startStreaming() {
        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()

            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            builder?.delegate = self

            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { success, error in
                if let error = error {
                    print("❌ Begin collection error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to start session: \(error.localizedDescription)")
        }
    }

    func stopStreaming() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { success, error in
            if let error = error {
                print("❌ End collection error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delegate
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard collectedTypes.contains(HKQuantityType.quantityType(forIdentifier: .heartRate)!) else { return }

        if let statistics = workoutBuilder.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!) {
            let unit = HKUnit.count().unitDivided(by: .minute())
            if let value = statistics.mostRecentQuantity()?.doubleValue(for: unit) {
                DispatchQueue.main.async {
                    self.bpm = value
                }
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
        print("Workout event collected")
    }
}
