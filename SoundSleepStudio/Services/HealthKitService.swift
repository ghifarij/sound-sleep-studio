import Foundation
import HealthKit
import SwiftUI

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private var updateTimer: Timer?
    
    @Published var currentHeartRate: Double = 0
    @Published var isAuthorized: Bool = false
    
    // For preview mode
    var isPreviewMode: Bool = false
    var previewHeartRate: Double = 0
    
    init(previewMode: Bool = false, previewHeartRate: Double = 0) {
        self.isPreviewMode = previewMode
        self.previewHeartRate = previewHeartRate
        
        if previewMode {
            self.currentHeartRate = previewHeartRate
            self.isAuthorized = true
        } else {
            // Set up automatic refresh
            setupAutomaticRefresh()
            
            // Check authorization on init
            checkAuthorizationStatus()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Public Methods
    func requestAuthorization() {
        if isPreviewMode { return }
        
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    // Immediately fetch heart rate after authorization
                    self?.fetchLatestHeartRate()
                } else {
                    self?.isAuthorized = false
                    if let error = error {
                        print("HealthKit authorization failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        if isPreviewMode { return }
        
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                // If not determined, request authorization
                self.requestAuthorization()
                
            case .sharingAuthorized:
                self.isAuthorized = true
                // Immediately fetch heart rate data
                self.fetchLatestHeartRate()
                
            case .sharingDenied:
                self.isAuthorized = false
                self.currentHeartRate = 0
                
            @unknown default:
                self.isAuthorized = false
                self.currentHeartRate = 0
            }
        }
    }
    
    func refresh() {
        if isPreviewMode { return }
        
        // Always check authorization status first
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        switch status {
        case .sharingAuthorized:
            fetchLatestHeartRate()
        case .notDetermined:
            requestAuthorization()
        case .sharingDenied, _:
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.currentHeartRate = 0
            }
        }
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
        
        // Skip if not authorized
        guard healthStore.authorizationStatus(for: heartRateType) == .sharingAuthorized else {
            return
        }
        
        // Create query for latest heart rate over past hour
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
            limit: 5,  // Get the 5 most recent samples
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (_, samples, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Handle errors
                if let error = error {
                    print("Error fetching heart rate: \(error.localizedDescription)")
                    return
                }
                
                // Get most recent value
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    // No samples found - this is normal if no recent heart rate data exists
                    return
                }
                
                // Convert to BPM
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
                
                // Update the UI with the heart rate
                self.currentHeartRate = heartRate
            }
        }
        
        // Execute the query
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