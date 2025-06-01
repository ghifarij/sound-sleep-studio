//
//  HealthKitService2.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 27/05/25.
//

import Foundation
import SwiftUI
import WatchConnectivity

class HeartRateController: NSObject, ObservableObject, WCSessionDelegate {
    @Published var bpm: Double = 0.0

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

    func startHeartRate() {
        if WCSession.default.isReachable {
    
            WCSession.default.sendMessage(
                ["command": "start"], replyHandler: nil)
            print("sucessfully send start message")
        }
    }

    func stopHeartRate() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(
                ["command": "stop"], replyHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        if let bpmValue = message["bpm"] as? Double {
            DispatchQueue.main.async {
                self.bpm = bpmValue
            }
        }
        if let Value = message["status"] as? String {
            print(Value)
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}
    func sessionDidBecomeInactive(_ session: WCSession) {
        WCSession.default.activate()
        print("")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
        print("deactive")
    }
}
