import SwiftUI
import SwiftData
import Foundation

class StreakManager {
    
   static func checkAndResetStreaks(context: ModelContext, healthKitManager: HealthKitManager) {
        print("Starting streak check...")
        
       
        let descriptor = FetchDescriptor<HealthGoal>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        guard let goals = try? context.fetch(descriptor) else {
            print("Could not fetch goals for streak check")
            return
        }
        
        print("Checking \(goals.count) goals for streak resets...")
        
        let calendar = Calendar.current
        let now = Date()
        
        for goal in goals {
            guard let period = GoalManager.TimePeriod(rawValue: goal.period) else {
                continue
            }
            
            let shouldReset = shouldResetStreak(
                goal: goal,
                period: period,
                currentDate: now,
                calendar: calendar,
                healthKitManager: healthKitManager
            )
            
            if shouldReset {
                print(" Resetting streak for: \(goal.goalName) (was \(goal.streakCount))")
                goal.streakCount = 0
                
                do {
                    try context.save()
                } catch {
                    print(" Error saving streak reset: \(error)")
                }
            } else {
                print("   ✓ \(goal.goalName) - Streak safe: \(goal.streakCount)")
            }
        }
        
        print("Streak check complete")
    }
    
    
    private static func shouldResetStreak(
        goal: HealthGoal,
        period: GoalManager.TimePeriod,
        currentDate: Date,
        calendar: Calendar,
        healthKitManager: HealthKitManager
    ) -> Bool {
        
        guard let lastCompleted = goal.lastCompleted else {
            return false
        }
        
        let currentProgress = GoalManager.calculateProgress(goal: goal, healthKitManager: healthKitManager)
        let isCurrentlyCompleted = GoalManager.isGoalCompleted(current: currentProgress, target: goal.trackableGoal)
        
        if isCurrentlyCompleted {
            return false
        }
        
   
        switch period {
        case .day:
            let isToday = calendar.isDate(lastCompleted, inSameDayAs: currentDate)
            let isYesterday = calendar.isDate(
                lastCompleted,
                inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            )
            
            return !isToday && !isYesterday
            
        case .week:
            let lastWeek = calendar.component(.weekOfYear, from: lastCompleted)
            let currentWeek = calendar.component(.weekOfYear, from: currentDate)
            let lastYear = calendar.component(.year, from: lastCompleted)
            let currentYear = calendar.component(.year, from: currentDate)
            
            let isCurrentWeek = (lastWeek == currentWeek && lastYear == currentYear)
            let isPreviousWeek = (lastWeek == currentWeek - 1 && lastYear == currentYear) ||
                                 (lastWeek == 52 && currentWeek == 1 && lastYear == currentYear - 1)
            
            return !isCurrentWeek && !isPreviousWeek
            
        case .month:
            let lastMonth = calendar.component(.month, from: lastCompleted)
            let currentMonth = calendar.component(.month, from: currentDate)
            let lastYear = calendar.component(.year, from: lastCompleted)
            let currentYear = calendar.component(.year, from: currentDate)
            
            let isCurrentMonth = (lastMonth == currentMonth && lastYear == currentYear)
            let isPreviousMonth = (lastMonth == currentMonth - 1 && lastYear == currentYear) ||
                                  (lastMonth == 12 && currentMonth == 1 && lastYear == currentYear - 1)
            
            return !isCurrentMonth && !isPreviousMonth
        }
    }
}
