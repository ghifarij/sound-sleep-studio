//
//  HealthKitService.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 20/05/25.
//

import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    @Published var currentHeartRate: Double = 0
    @Published var isAuthorized: Bool = false
    // We'll use a new state to track if the initial authorization check is complete
    @Published var initialAuthCheckComplete: Bool = false
    
    private var isFirstLaunchAttempt: Bool = true // To ensure requestAuthorization is called only once automatically
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.fetchLatestHeartRate()
                    self?.setupHeartRateObserver()
                } else {
                    self?.currentHeartRate = 0 // Reset heart rate if not authorized
                    if let error = error {
                        print("HealthKit authorization failed: \(error.localizedDescription)")
                    }
                }
                // Mark initial check as complete regardless of success or failure
                self?.initialAuthCheckComplete = true
            }
        }
    }
    
    func startHeartRateQuery() {
        // Get the most recent heart rate sample
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKQuantitySample else {
                return
            }
            
            // Get the heart rate in beats per minute
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                self?.currentHeartRate = heartRate
            }
        }
        
        healthStore.execute(query)
        
        // Set up a background query to update heart rate periodically
        setupHeartRateObserver()
    }
    
    func setupHeartRateObserver() {
        // Create a predicate to only get new samples
        let datePredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        
        // Create the query
        let query = HKObserverQuery(sampleType: heartRateType, predicate: datePredicate) { [weak self] (query, completionHandler, error) in
            if let error = error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            
            // Fetch the latest heart rate
            self?.fetchLatestHeartRate()
            
            // Call the completion handler
            completionHandler()
        }
        
        // Execute the query
        healthStore.execute(query)
        
        // Also, start background delivery if available
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { (success, error) in
            if let error = error {
                print("Background delivery setup error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchLatestHeartRate() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKQuantitySample else {
                return
            }
            
            // Get the heart rate in beats per minute
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                self?.currentHeartRate = heartRate
            }
        }
        
        healthStore.execute(query)
    }
    func checkAuthorizationStatus() {
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                // If it's the first time the app is launched and status is not determined,
                // request authorization. This will show the system prompt.
                if self.isFirstLaunchAttempt {
                    self.isFirstLaunchAttempt = false // Prevent multiple automatic requests
                    self.requestAuthorization()
                } else {
                    // If not the first attempt (e.g. user dismissed prompt),
                    // consider it not authorized until they manually grant it.
                    self.isAuthorized = false
                    self.currentHeartRate = 0
                    self.initialAuthCheckComplete = true
                }
            case .sharingAuthorized:
                self.isAuthorized = true
                self.fetchLatestHeartRate()
                self.setupHeartRateObserver()
                self.initialAuthCheckComplete = true
            case .sharingDenied:
                self.isAuthorized = false
                self.currentHeartRate = 0
                self.initialAuthCheckComplete = true
            @unknown default:
                self.isAuthorized = false
                self.currentHeartRate = 0
                self.initialAuthCheckComplete = true
            }
        }
    }
}