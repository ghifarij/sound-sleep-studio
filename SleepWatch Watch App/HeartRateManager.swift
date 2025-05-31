import HealthKit
import WatchConnectivity

class HeartRateManager: NSObject,
    HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate, WCSessionDelegate {

    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var isWorkoutRunning = false

    override init() {
        super.init()
        requestAuthorization()
        if WCSession.default.isReachable {
                WCSession.default.sendMessage(["status": "awake"], replyHandler: nil)
            }
    }

    // MARK: - WCSession Setup
    private func setupWCSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - WCSession Delegate
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if message["command"] as? String == "start" {
            startStreaming()
        } else if message["command"] as? String == "stop" {
            stopStreaming()
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("WCSession error: \(error.localizedDescription)")
        }
    }

    // MARK: - Authorization
    func requestAuthorization() {
        let readTypes: Set = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        let shareTypes: Set = [HKObjectType.workoutType()]

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            if success {
                print("✅ HealthKit authorized")
            } else {
                print("❌ Authorization failed: \(String(describing: error))")
            }
        }
    }

    // MARK: - Start Streaming
    func startStreaming() {
        guard !isWorkoutRunning else {
            print("⚠️ Already running")
            return
        }

        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()

            session?.delegate = self
            builder?.delegate = self
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: config
            )

            session?.startActivity(with: Date())
            isWorkoutRunning = true
        } catch {
            print("❌ Session error: \(error.localizedDescription)")
        }
    }

    // MARK: - Stop Streaming
    func stopStreaming() {
        guard isWorkoutRunning else {
            print("⚠️ Workout not running")
            return
        }

        builder?.endCollection(withEnd: Date()) { success, error in
            if let error = error {
                print("❌ End collection error: \(error.localizedDescription)")
            } else {
                print("✅ Collection ended")
            }
        }

        session?.end()
        session = nil
        builder = nil
        isWorkoutRunning = false
    }

    // MARK: - Workout Session Delegate
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        if toState == .running {
            builder?.beginCollection(withStart: date) { success, error in
                if let error = error {
                    print("❌ Begin collection error: \(error.localizedDescription)")
                } else {
                    print("✅ Collection started")
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("❌ Workout session failed: \(error.localizedDescription)")
        isWorkoutRunning = false
    }

    // MARK: - Builder Delegate
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard collectedTypes.contains(HKQuantityType.quantityType(forIdentifier: .heartRate)!) else {
            return
        }

        if let stats = workoutBuilder.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!) {
            let unit = HKUnit.count().unitDivided(by: .minute())
            let bpm = stats.mostRecentQuantity()?.doubleValue(for: unit) ?? 0.0
            WCSession.default.sendMessage(["bpm": bpm], replyHandler: nil)
            print("❤️ BPM: \(bpm)")
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}

