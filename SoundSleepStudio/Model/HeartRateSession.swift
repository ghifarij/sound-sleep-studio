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
    
    var bpmRecords: [Double]
    var bpmTimeStamps: [Date]
    
    var minBpm: Double?
    var maxBpm: Double?
    var reachedRestingAt: Date?
    
    init(startDate: Date){
        self.startDate = startDate
        self.endDate = nil
        self.bpmRecords = []
        self.bpmTimeStamps = []
    }
}
