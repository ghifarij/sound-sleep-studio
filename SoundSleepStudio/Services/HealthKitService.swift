import Foundation
import HealthKit
import SwiftUI

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private var observerQuery: HKObserverQuery?
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var backgroundDeliveryEnabled = false
    private var queryAnchor: HKQueryAnchor?
    
    @Published var currentHeartRate: Double = 0
    
    // For preview mode
    var isPreviewMode: Bool = false
    var previewHeartRate: Double = 0
    
    init(previewMode: Bool = false, previewHeartRate: Double = 0) {
        self.isPreviewMode = previewMode
        self.previewHeartRate = previewHeartRate
        
        if previewMode {
            self.currentHeartRate = previewHeartRate
        } else {
            // Request authorization once at startup
            requestHealthKitPermission()
        }
    }
    
    deinit {
        stopQueries()
    }
    
    private func stopQueries() {
        if let query = observerQuery {
            healthStore.stop(query)
            print("HealthKit: Stopped observer query")
        }
        
        if let query = anchoredQuery {
            healthStore.stop(query)
            print("HealthKit: Stopped anchored query")
        }
    }
    
    // MARK: - Public Methods
    
    /// Request authorization for heart rate access with optional completion handler
    /// - Parameter completion: Callback with success/error information
    func requestHealthKitPermission(completion: ((Bool, Error?) -> Void)? = nil) {
        if isPreviewMode {
            completion?(true, nil)
            return
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = NSError(domain: "com.soundsleepstudio", code: 1, 
                              userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device"])
            print("HealthKit: Health data is not available on this device")
            completion?(false, error)
            return
        }
        
        // Request authorization
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            guard let self = self else {
                completion?(false, nil)
                return
            }
            
            if success {
                print("HealthKit: Authorization successful")
                DispatchQueue.main.async {
                    // Set up monitoring
                    self.setupHeartRateMonitoring()
                    
                    // Initial fetch
                    self.fetchLatestHeartRate()
                    
                    // Enable background delivery
                    self.enableBackgroundDelivery()
                    
                    // Call completion handler
                    completion?(true, nil)
                }
            } else {
                print("HealthKit: Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                completion?(false, error)
            }
        }
    }
    
    func refresh() {
        if isPreviewMode { return }
        fetchLatestHeartRate()
    }
    
    // MARK: - Private Methods
    private func setupHeartRateMonitoring() {
        stopQueries() // Ensure no duplicate queries
        
        // Create a predicate for heart rate updates - looking for all samples
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: nil, options: .strictEndDate)
        
        // Set up anchored query for continuous updates
        setupAnchoredQuery(predicate: predicate)
        
        // Set up observer query for notifications when new data is available
        setupObserverQuery(predicate: predicate)
    }
    
    private func setupObserverQuery(predicate: NSPredicate) {
        // Create an observer query that notifies us when new heart rate data is available
        observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: predicate) { [weak self] query, completionHandler, error in
            guard let self = self else {
                completionHandler()
                return
            }
            
            if let error = error {
                print("HealthKit: Observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            // New data is available, update via anchored query
            DispatchQueue.main.async {
                print("HealthKit: Observer triggered - new heart rate data available")
                self.updateHeartRateWithAnchoredQuery()
            }
            
            // Call the completion handler
            completionHandler()
        }
        
        // Start the observer query
        if let query = observerQuery {
            healthStore.execute(query)
            print("HealthKit: Heart rate observer started")
        }
    }
    
    private func setupAnchoredQuery(predicate: NSPredicate) {
        // Create an anchored query for retrieving updates
        anchoredQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: queryAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] (query, newSamples, deletedSamples, newAnchor, error) in
            guard let self = self else { return }
            
            // Update the anchor for future queries
            self.queryAnchor = newAnchor
            
            if let error = error {
                print("HealthKit: Anchored query error: \(error.localizedDescription)")
                return
            }
            
            if let samples = newSamples, !samples.isEmpty {
                print("HealthKit: Received \(samples.count) new heart rate samples")
                self.processHeartRateSamples(samples: samples)
            }
        }
        
        // Set up the update handler for continuous updates
        anchoredQuery?.updateHandler = { [weak self] (query, newSamples, deletedSamples, newAnchor, error) in
            guard let self = self else { return }
            
            // Update the anchor for future queries
            self.queryAnchor = newAnchor
            
            if let error = error {
                print("HealthKit: Anchored query update error: \(error.localizedDescription)")
                return
            }
            
            if let samples = newSamples, !samples.isEmpty {
                print("HealthKit: Received \(samples.count) new heart rate samples (update)")
                self.processHeartRateSamples(samples: samples)
            }
        }
        
        // Start the anchored query
        if let query = anchoredQuery {
            healthStore.execute(query)
            print("HealthKit: Heart rate anchored query started")
        }
    }
    
    private func updateHeartRateWithAnchoredQuery() {
        // We could just fetch the latest heart rate directly here,
        // but our anchored query's updateHandler will handle this
        // This is just a backup in case the anchored query doesn't fire
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchLatestHeartRate()
        }
    }
    
    private func processHeartRateSamples(samples: [HKSample]) {
        // Find the newest sample in the list
        guard let heartRateSamples = samples as? [HKQuantitySample],
              let latestSample = heartRateSamples.max(by: { $0.endDate < $1.endDate }) else {
            return
        }
        
        // Extract the heart rate value
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let heartRate = latestSample.quantity.doubleValue(for: heartRateUnit)
        let timestamp = latestSample.endDate
                
        // Update the UI on the main thread
        DispatchQueue.main.async {
            print("HealthKit: Updated heart rate to \(heartRate) BPM (timestamp: \(timestamp))")
            self.currentHeartRate = heartRate
        }
    }
    
    private func enableBackgroundDelivery() {
        // Request background updates for heart rate
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            if success {
                print("HealthKit: Background updates enabled")
                self.backgroundDeliveryEnabled = true
            } else if let error = error {
                print("HealthKit: Failed to enable background updates: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchLatestHeartRate() {
        if isPreviewMode { return }
        
        // Create query for latest heart rate over past 1 hour (reduced from 6 hours)
        let calendar = Calendar.current
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(
            withStart: hourAgo,
            end: Date(),
            options: .strictEndDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Create the query
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: 1,  // We only need the most recent sample
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (_, samples, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("HealthKit: Query error: \(error.localizedDescription)")
                    return
                }
                
                // Get most recent value if available
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    print("HealthKit: No heart rate samples found")
                    return
                }
                
                // Convert to BPM
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
                let timestamp = mostRecentSample.endDate
                
                print("HealthKit: Updated heart rate to \(heartRate) BPM (timestamp: \(timestamp))")
                
                // Update the UI with the heart rate
                self.currentHeartRate = heartRate
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
}
