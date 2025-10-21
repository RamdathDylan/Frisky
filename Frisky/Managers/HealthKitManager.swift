import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    @Published var todaySteps: Int = 0
    @Published var todaySleepHours: Double = 0
    @Published var todayHeartRateAvg: Int = 0
    @Published var todayActiveMinutes: Double = 0
    @Published var todayExerciseMinutes: Double = 0

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
    
    private func createPredicateForDay(date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
    }
}



enum HealthKitError: Error {
    case notAvailable
    case authorizationFailed
    case dataNotAvailable
}
