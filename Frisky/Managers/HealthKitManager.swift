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
    
        func fetchSteps(for date: Date) async throws -> Int {
            let stepType = HKQuantityType(.stepCount)
            let predicate = createPredicateForDay(date: date)
            
            let steps = try await fetchQuantitySum(for: stepType, predicate: predicate)
            return Int(steps)
        }
        
        func fetchSleepHours(for date: Date) async throws -> Double {
            let sleepType = HKCategoryType(.sleepAnalysis)
            let predicate = createPredicateForDay(date: date)
            
            let descriptor = HKSampleQueryDescriptor(
                predicates: [.categorySample(type: sleepType, predicate: predicate)],
                sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)]
            )
            
            let samples = try await descriptor.result(for: healthStore)
            
            var totalSleepSeconds: TimeInterval = 0
            for sample in samples {
                if sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue {
                    totalSleepSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                }
            }
            
            return totalSleepSeconds / 3600 
        }
        
        func fetchAverageHeartRate(for date: Date) async throws -> Int {
            let heartRateType = HKQuantityType(.heartRate)
            let predicate = createPredicateForDay(date: date)
            
            let average = try await fetchQuantityAverage(for: heartRateType, predicate: predicate)
            return Int(average)
        }
        
        func fetchActiveMinutes(for date: Date) async throws -> Double {
            let moveType = HKQuantityType(.appleMoveTime)
            let predicate = createPredicateForDay(date: date)
            
            let minutes = try await fetchQuantitySum(for: moveType, predicate: predicate)
            return minutes
        }
        
        func fetchExerciseMinutes(for date: Date) async throws -> Double {
            let exerciseType = HKQuantityType(.appleExerciseTime)
            let predicate = createPredicateForDay(date: date)
            
            let minutes = try await fetchQuantitySum(for: exerciseType, predicate: predicate)
            return minutes
        }
    }




enum HealthKitError: Error {
    case notAvailable
    case authorizationFailed
    case dataNotAvailable
}
