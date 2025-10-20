import Foundation
import SwiftData

@Model
class HealthGoal {
    var goalName: String
    var habitType: String // "steps", "sleep", "active", "exercise", "water", "meditation"
    var trackableGoal: Double // Target value (e.g., 10000 steps, 8 hours sleep)
    var period: String // intervals: "day", "week" ... 
    var streakCount: Int
    var lastCompleted: Date?
    var isActive: Bool
    var createdDate: Date
    
    init(
        goalName: String,
        habitType: String,
        trackableGoal: Double,
        period: String = "day"
    ) {
        self.goalName = goalName
        self.habitType = habitType
        self.trackableGoal = trackableGoal
        self.period = period
        self.streakCount = 0
        self.isActive = true
        self.createdDate = Date()
    }
}
