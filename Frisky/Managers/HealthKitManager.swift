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
    
    private func fetchQuantitySum(for quantityType: HKQuantityType, predicate: NSPredicate) async throws -> Double {
            let descriptor = HKSampleQueryDescriptor(
                predicates: [.quantitySample(type: quantityType, predicate: predicate)],
                sortDescriptors: []
            )

            let samples = try await descriptor.result(for: healthStore)

            let total = samples.reduce(0.0) { sum, sample in
                let unit: HKUnit
                switch quantityType {
                case HKQuantityType(.stepCount):
                    unit = .count()
                case HKQuantityType(.appleExerciseTime), HKQuantityType(.appleMoveTime):
                    unit = .minute()
                default:
                    unit = .count()
                }
                return sum + sample.quantity.doubleValue(for: unit)
            }

            return total
        }
    private func fetchQuantityAverage(for quantityType: HKQuantityType, predicate: NSPredicate) async throws -> Double {
            let descriptor = HKSampleQueryDescriptor(
                predicates: [.quantitySample(type: quantityType, predicate: predicate)],
                sortDescriptors: []
            )

            let samples = try await descriptor.result(for: healthStore)

            guard !samples.isEmpty else { return 0 }

            let total = samples.reduce(0.0) { sum, sample in
                let unit: HKUnit = (quantityType == HKQuantityType(.heartRate)) ?
                    HKUnit.count().unitDivided(by: .minute()) : .count()
                return sum + sample.quantity.doubleValue(for: unit)
            }

            return total / Double(samples.count)
        }
    }



enum HealthKitError: Error {
    case notAvailable
    case authorizationFailed
    case dataNotAvailable
}
