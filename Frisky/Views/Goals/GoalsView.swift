import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var healthKitManager = HealthKitManager.shared
    
    @State private var showingAddGoal = false
    @State private var goalToDelete: HealthGoal?
    @State private var showingDeleteConfirmation = false
    
    @Query(filter: #Predicate<HealthGoal> { goal in
        goal.isActive == true
    }, sort: \HealthGoal.createdDate) private var activeGoals: [HealthGoal]
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                List {
                    Section {
                        placeholderCatSection
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        ForEach(activeGoals) { goal in
                            GoalCard(
                                goal: goal,
                                healthKitManager: healthKitManager
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 7.5, leading: 0, bottom: 7.5, trailing: 0))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    goalToDelete = goal
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    Section {
                        addGoalButton
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 20)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 100)
                }
            }
        }
        .onAppear {
            Task {
                print(" GoalsView: Requesting HealthKit authorization...")
                try? await healthKitManager.requestAuthorization()
                healthKitManager.startObservingTodayData()
                
                await healthKitManager.updateTodayStats()
                
                print(" GoalsView: Health data loaded")
                print("   Steps: \(healthKitManager.todaySteps)")
                print("   Sleep: \(healthKitManager.todaySleepHours)")
                print("   Exercise: \(healthKitManager.todayExerciseMinutes)")
                
                
                StreakManager.checkAndResetStreaks(context: modelContext, healthKitManager: healthKitManager)
            }
            
            GoalManager.createDefaultGoals(context: modelContext)
        }
        
        .onDisappear {
            healthKitManager.stopObserving()
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView()
        }
        .alert("Delete Goal?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let goal = goalToDelete {
                    deleteGoal(goal)
                }
            }
        } message: {
            if let goal = goalToDelete {
                Text("Are you sure you want to delete '\(goal.goalName)'? This cannot be undone.")
            }
        }
    }
    
    var placeholderCatSection: some View {
        VStack(spacing: 15) {
            
            AnimatedEatingCatView()
            
            Text("Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    var addGoalButton: some View {
        Button(action: {
            showingAddGoal = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add Goal")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .padding(.top, 10)
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
    
    func deleteGoal(_ goal: HealthGoal) {
        goal.isActive = false
        
        do {
            try modelContext.save()
            print(" Deleted goal: \(goal.goalName)")
        } catch {
            print(" Error deleting goal: \(error)")
        }
        
        goalToDelete = nil
    }
}

struct GoalCard: View {
    
    let goal: HealthGoal
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
           
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: goalType.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(goalType.color))
                    
                    Text(goalType.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(goalType.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(goalType.color.opacity(0.15))
                        .cornerRadius(8)
                }
                
                Spacer()
                
              
                if goal.streakCount > 0 {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(goal.streakCount)")
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(20)
                }
            }
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.goalName)
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Text("\(targetText) / \(timePeriod.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let periodText = periodDayText {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(periodText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
         
            HStack {
                Text("\(currentText) / \(targetText) \(goalType.unit)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(percentageText)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isCompleted ? .green : .blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(isCompleted ? Color.green : goalType.color)  // Use goal type color
                        .frame(width: geometry.size.width * CGFloat(percentage), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
    
    var goalType: GoalManager.GoalType {
        GoalManager.GoalType(rawValue: goal.habitType) ?? .steps
    }
    
    var timePeriod: GoalManager.TimePeriod {
        GoalManager.TimePeriod(rawValue: goal.period) ?? .day
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
    
    var currentText: String {
        GoalManager.formatNumber(currentProgress, type: goalType)
    }
    
    var targetText: String {
        GoalManager.formatNumber(goal.trackableGoal, type: goalType)
    }
    
    var percentageText: String {
        String(format: "%.0f", percentage * 100)
    }
    
    var periodDayText: String? {
        let calendar = Calendar.current
        let today = Date()
        
        switch timePeriod {
        case .day:
           
            return nil
            
        case .week:
            
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
            let daysIntoWeek = calendar.dateComponents([.day], from: startOfWeek, to: today).day ?? 0
            return "Day \(daysIntoWeek + 1) of Week"
            
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
            let daysIntoMonth = calendar.dateComponents([.day], from: startOfMonth, to: today).day ?? 0
            return "Day \(daysIntoMonth + 1) of Month"
        }
    }
    
}

#Preview {
    GoalsView()
        .modelContainer(for: [HealthGoal.self, UserProfile.self, Pet.self, CheckIn.self, DailyHealthData.self])
}
