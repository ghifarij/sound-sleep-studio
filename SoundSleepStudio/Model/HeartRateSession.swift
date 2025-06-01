//
//  HeartRateSession.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 22/05/25.
//
import Foundation
import SwiftData

@Model
class HeartRateSession {
    var id = UUID()
    var startDate: Date
    var endDate: Date?

    @Relationship(deleteRule: .cascade)
    var bpmRecords: [BpmRecord] = []

    var minBpm: Double?
    var maxBpm: Double?
    var reachedRestingAt: Date?
    
    init(startDate: Date) {
        self.startDate = startDate
    }
}

@Model
class BpmRecord {
    var value: Double
    var timestamp: Date
    var session: HeartRateSession?
    
    init(timestamp: Date, bpm: Double, session: HeartRateSession? = nil) {
            self.timestamp = timestamp
        self.value = bpm
            self.session = session
        }
}

