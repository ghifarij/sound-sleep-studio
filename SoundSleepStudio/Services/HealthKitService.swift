import Foundation
import HealthKit
import SwiftUI

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private var updateTimer: Timer?
    
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
            // Request authorization once at startup - no need to check result
            requestInitialAuthorization()
            
            // Set up automatic refresh
            setupAutomaticRefresh()
            
            // Fetch data immediately
            fetchLatestHeartRate()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Public Methods
    private func requestInitialAuthorization() {
        // One-time authorization request - no need to check result
        let typesToRead: Set<HKObjectType> = [heartRateType]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] _, _ in
            // Fetch data regardless of authorization result
            DispatchQueue.main.async {
                self?.fetchLatestHeartRate()
            }
        }
    }
    
    func refresh() {
        if isPreviewMode { return }
        fetchLatestHeartRate()
    }
    
    // MARK: - Private Methods
    private func setupAutomaticRefresh() {
        // Update every 5 seconds to catch any new heart rate data
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.fetchLatestHeartRate()
        }
    }
    
    private func fetchLatestHeartRate() {
        if isPreviewMode { return }
        
        // Create query for latest heart rate over past 6 hours
        let calendar = Calendar.current
        let hoursAgo = calendar.date(byAdding: .hour, value: -6, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(
            withStart: hoursAgo,
            end: Date(),
            options: .strictEndDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Create the query
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: 10,  // Get the 10 most recent samples
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (_, samples, _) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Get most recent value if available
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    // No samples found - heart rate stays at default (0)
                    return
                }
                
                // Convert to BPM
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
                
                // Update the UI with the heart rate
                self.currentHeartRate = heartRate
            }
        }
        
        // Execute the query - if this fails, heart rate will just stay at 0
        healthStore.execute(query)
    }
}

// Preview helper extension
extension HealthKitService {
    static var preview60BPM: HealthKitService {
        HealthKitService(previewMode: true, previewHeartRate: 60)
    }
    
    static var preview80BPM: HealthKitService {
        HealthKitService(previewMode: true, previewHeartRate: 80)
    }
    
    static var preview100BPM: HealthKitService {
        HealthKitService(previewMode: true, previewHeartRate: 100)
    }
    
    static var preview120BPM: HealthKitService {
        HealthKitService(previewMode: true, previewHeartRate: 120)
    }
}