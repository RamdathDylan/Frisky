import SwiftUI
import SwiftData

class GoalManager {
    
    
    enum GoalType: String, CaseIterable {
        case steps
        case sleep
        case exercise
        case activeTime
        
        var title: String {
            switch self {
            case .steps: return "Steps"
            case .sleep: return "Sleep"
            case .exercise: return "Exercise"
            case .activeTime: return "Active Time"
            }
        }
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .sleep: return "bed.double.fill"
            case .exercise: return "flame.fill"
            case .activeTime: return "figure.run"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .blue
            case .sleep: return .purple
            case .exercise: return .orange
            case .activeTime: return .green
            }
        }
        
        var unit: String {
            switch self {
            case .steps: return "steps"
            case .sleep: return "hours"
            case .exercise: return "minutes"
            case .activeTime: return "minutes"
            }
        }
        
        var defaultGoal: Double {
            switch self {
            case .steps: return 10000
            case .sleep: return 8
            case .exercise: return 30
            case .activeTime: return 60
            }
        }
    }
    
    enum TimePeriod: String, Codable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        
        var emoji: String {
            switch self {
            case .day:
                return "📅"
            case .week:
                return "📆"
            case .month:
                return "🗓️"
            }
        }
    }
    
    static func createDefaultGoals(context: ModelContext) {
        let descriptor = FetchDescriptor<HealthGoal>()
        let existingGoals = try? context.fetch(descriptor)
        
        if let goals = existingGoals, !goals.isEmpty {
            print("Goals already exist, skipping defaults")
            return
        }
        
        let stepsGoal = HealthGoal(
            goalName: "Daily Steps",
            habitType: GoalType.steps.rawValue,
            trackableGoal: 10000,
            period: TimePeriod.day.rawValue
        )
        context.insert(stepsGoal)
        
        let sleepGoal = HealthGoal(
            goalName: "Good Sleep",
            habitType: GoalType.sleep.rawValue,
            trackableGoal: 8,
            period: TimePeriod.day.rawValue
        )
        context.insert(sleepGoal)
        let exerciseGoal = HealthGoal(
            goalName: "Daily Exercise",
            habitType: GoalType.exercise.rawValue,
            trackableGoal: 30,
            period: TimePeriod.day.rawValue
        )
        context.insert(exerciseGoal)
        

        try? context.save()
        print(" Created 3 default goals")
    }
    static func calculateProgress(goal: HealthGoal, healthKitManager: HealthKitManager) -> Double {
        let goalType = GoalType(rawValue: goal.habitType) ?? .steps
        
        switch goalType {
        case .steps:
            return Double(healthKitManager.todaySteps)
        case .sleep:
            return healthKitManager.todaySleepHours
        case .exercise:
            return healthKitManager.todayExerciseMinutes
        case .activeTime:
            return healthKitManager.todayExerciseMinutes
        }
    }
    static func calculatePercentage(current: Double, target: Double) -> Double {
        guard target > 0 else { return 0 }
        let percentage = current / target
        return min(percentage, 1.0)
    }
    
    static func isGoalCompleted(current: Double, target: Double) -> Bool {
        return current >= target
    }
    
  
    static func formatNumber(_ value: Double, type: GoalType) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = (type == .sleep) ? 1 : 0
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
