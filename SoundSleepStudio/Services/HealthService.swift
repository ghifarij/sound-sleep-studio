//
//  HealthKitService2.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 27/05/25.
//

import HealthKit

@Observable
class HealthService {
    var bpm: Double = 0.0
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var anchor: HKQueryAnchor?
    private var query: HKAnchoredObjectQuery?
    
    func start() {
        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .indoor
        
    
    }
    
}
