import SwiftUI
import SwiftData

struct RecapView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var healthKitManager = HealthKitManager.shared
    
    
    @State private var showHistoricalChart = false
    
   
    
    @Query(filter: #Predicate<HealthGoal> { goal in
        goal.isActive == true
    }) private var activeGoals: [HealthGoal]
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                
                headerSection
                
                
                ScrollView {
                    VStack(spacing: 20) {
                        historicalChartButton
                        
                   
                        weeklySummaryCard
      
                        todayStatsCard
                        
                        goalsOverviewCard
                        
                        streakSummaryCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            Task {
                try? await healthKitManager.requestAuthorization()
                healthKitManager.startObservingTodayData()
                await healthKitManager.updateTodayStats()
            }
        }
        .sheet(isPresented: $showHistoricalChart) {
            HistoricalChartView()
        }
    }
    
    var historicalChartButton: some View {
        Button(action: {
            showHistoricalChart = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("View Historical Data")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text("See your progress over time")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
    }
    
   
    var headerSection: some View {
        Text("Recap")
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
    }
 
    var weeklySummaryCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("📅 This Week")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(weekDateRange)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
          
            VStack(spacing: 12) {
                WeekStatRow(
                    icon: "figure.walk",
                    label: "Steps",
                    value: "\(formatNumber(weeklySteps))",
                    color: .blue
                )
                
                WeekStatRow(
                    icon: "bed.double.fill",
                    label: "Sleep",
                    value: "\(formatDecimal(weeklySleep)) hrs",
                    color: .purple
                )
                
                WeekStatRow(
                    icon: "flame.fill",
                    label: "Exercise",
                    value: "\(formatNumber(weeklyExercise)) min",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    var todayStatsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(" Today")
                .font(.title3)
                .fontWeight(.bold)
            
            Divider()
            
            VStack(spacing: 12) {
                TodayStatRow(
                    icon: "figure.walk",
                    label: "Steps",
                    value: "\(healthKitManager.todaySteps)",
                    color: .blue
                )
                
                TodayStatRow(
                    icon: "bed.double.fill",
                    label: "Sleep",
                    value: "\(formatDecimal(healthKitManager.todaySleepHours)) hours",
                    color: .purple
                )
                
                TodayStatRow(
                    icon: "flame.fill",
                    label: "Exercise",
                    value: "\(Int(healthKitManager.todayExerciseMinutes)) minutes",
                    color: .orange
                )
                
                TodayStatRow(
                    icon: "heart.fill",
                    label: "Heart Rate",
                    value: "\(healthKitManager.todayHeartRateAvg) bpm",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    

    var goalsOverviewCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(" Goals Progress")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(completedGoalsCount)/\(activeGoals.count)")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Divider()
            
            if activeGoals.isEmpty {
                Text("No active goals")
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 10) {
                    ForEach(activeGoals) { goal in
                        GoalProgressRow(goal: goal, healthKitManager: healthKitManager)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    var streakSummaryCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🔥 Streaks")
                .font(.title3)
                .fontWeight(.bold)
            
            Divider()
            
            if activeGoals.isEmpty {
                Text("No streaks yet")
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 10) {
                    ForEach(activeGoals.sorted(by: { $0.streakCount > $1.streakCount })) { goal in
                        StreakRow(goal: goal)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    
    var backgroundColor: some View {
        LinearGradient(
            colors: [
                Color(red: 0.6, green: 0.6, blue: 0.9),
                Color(red: 0.7, green: 0.7, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
   
    
    var weeklySteps: Double {
        Double(healthKitManager.todaySteps) * 7
    }
    
    var weeklySleep: Double {
        healthKitManager.todaySleepHours * 7
    }
    
    var weeklyExercise: Double {
        healthKitManager.todayExerciseMinutes * 7
    }
    
    var weekDateRange: String {
        let calendar = Calendar.current
        let today = Date()
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return ""
        }
        
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? today
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    var completedGoalsCount: Int {
        activeGoals.filter { goal in
            let progress = GoalManager.calculateProgress(goal: goal, healthKitManager: healthKitManager)
            return GoalManager.isGoalCompleted(current: progress, target: goal.trackableGoal)
        }.count
    }
    

    func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
    
    func formatDecimal(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}


struct WeekStatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct TodayStatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
        }
    }
}

struct GoalProgressRow: View {
    let goal: HealthGoal
    let healthKitManager: HealthKitManager
    
    var body: some View {
        HStack(spacing: 10) {
            // Goal icon
            Image(systemName: goalType.icon)
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(isCompleted ? Color.green : Color.gray))
            
            // Goal name
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.goalName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(progressText)%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Text("\(progressText)%")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
        }
    }
    
    var goalType: GoalManager.GoalType {
        GoalManager.GoalType(rawValue: goal.habitType) ?? .steps
    }
    
    var currentProgress: Double {
        GoalManager.calculateProgress(goal: goal, healthKitManager: healthKitManager)
    }
    
    var percentage: Double {
        GoalManager.calculatePercentage(current: currentProgress, target: goal.trackableGoal)
    }
    
    var isCompleted: Bool {
        GoalManager.isGoalCompleted(current: currentProgress, target: goal.trackableGoal)
    }
    
    var progressText: String {
        String(format: "%.0f", percentage * 100)
    }
}

struct StreakRow: View {
    let goal: HealthGoal
    
    var body: some View {
        HStack {
            Text(goal.goalName)
                .font(.subheadline)
            
            Spacer()
            
            if goal.streakCount > 0 {
                HStack(spacing: 4) {
                    Text("🔥")
                    Text("\(goal.streakCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            } else {
                Text("No streak")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    RecapView()
        .modelContainer(for: [HealthGoal.self, UserProfile.self, Pet.self, CheckIn.self, DailyHealthData.self])
}
