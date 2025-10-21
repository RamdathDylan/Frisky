import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    let healthDataToRead: Set<HKSampleType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.heartRate),
        HKQuantityType(.appleExerciseTime),
        HKQuantityType(.appleMoveTime),
        HKCategoryType(.sleepAnalysis) ]
    
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()}

    func requestAuthorization() async throws {
        guard isHealthKitAvailable() else {
            throw HealthKitError.notAvailable }

        try await healthStore.requestAuthorization(toShare: [], read: healthDataToRead)

        await MainActor.run {
            self.isAuthorized = true
        }
    }
}

enum HealthKitError: Error {
    case notAvailable
    case authorizationFailed
    case dataNotAvailable
}
