import Foundation
import SwiftData

@Model
class DailyHealthData {
    var date: Date
    var steps: Int
    var sleepHours: Double
    var heartRateAvg: Int
    var activeTime: Double 
    var exerciseMinutes: Double
    var sleepAnalysis: String
    
    init(
        date: Date,
        steps: Int = 0,
        sleepHours: Double = 0,
        heartRateAvg: Int = 0,
        activeTime: Double = 0,
        exerciseMinutes: Double = 0,
        sleepAnalysis: String = "unknown"
    ) {
        self.date = date
        self.steps = steps
        self.sleepHours = sleepHours
        self.heartRateAvg = heartRateAvg
        self.activeTime = activeTime
        self.exerciseMinutes = exerciseMinutes
        self.sleepAnalysis = sleepAnalysis
    }
}
