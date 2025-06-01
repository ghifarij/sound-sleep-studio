//
//  HealthKitService2.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 27/05/25.
//

import Foundation
import SwiftData
import SwiftUI
import WatchConnectivity

class HeartRateController: NSObject, ObservableObject, WCSessionDelegate {
    @Published var bpm: Double = 0.0
    var modelContext: ModelContext?
    var currentSession: HeartRateSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("watch is supoorted")
        } else {
            print("watch is not supported")
        }
    }

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func startHeartRate() {
        if WCSession.default.isReachable {
            let startOfToday = Calendar.current.startOfDay(for: Date())
            let descriptor = FetchDescriptor<HeartRateSession>(
                predicate: #Predicate { $0.startDate >= startOfToday }
            )
            if let todaySession = try? modelContext?.fetch(descriptor).first {
                modelContext?.delete(todaySession)
            }
            let newSession = HeartRateSession(startDate: Date())
            modelContext?.insert(newSession)
            currentSession = newSession
            let bpmR = BpmRecord(timestamp: Date(), bpm: 70)
            currentSession?.bpmRecords.append(bpmR)
            WCSession.default.sendMessage(
                ["command": "start"], replyHandler: nil)
            print("sucessfully send start message")
        }
    }

    func stopHeartRate() {
        if WCSession.default.isReachable {
            currentSession?.endDate = Date()
            try? modelContext?.save()
            WCSession.default.sendMessage(
                ["command": "stop"], replyHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        if let bpmValue = message["bpm"] as? Double {
            DispatchQueue.main.async {
                self.bpm = bpmValue

                let record = BpmRecord(
                    timestamp: Date(), bpm: bpmValue,
                    session: self.currentSession)
                self.currentSession?.bpmRecords.append(record)

                self.currentSession?.minBpm = min(
                    self.currentSession?.minBpm ?? bpmValue, bpmValue)
                self.currentSession?.maxBpm = max(
                    self.currentSession?.maxBpm ?? bpmValue, bpmValue)
            }
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}
    func sessionDidBecomeInactive(_ session: WCSession) {

    }
    func sessionDidDeactivate(_ session: WCSession) {

    }
}
