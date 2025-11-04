import SwiftUI
import SwiftData

// Celebration data wrapper
struct CelebrationData: Identifiable {
    let id = UUID()
    let goal: HealthGoal
    let progress: Double
}

struct HomeView: View {
    @ObservedObject private var healthKitManager = HealthKitManager.shared
    
    
    @Environment(\.modelContext) private var modelContext
    @State private var celebration: CelebrationData?
    
    
    @State private var currentLevel: Int = 1
    @State private var currentXP: Int = 45
    @State private var xpNeeded: Int = 100
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                
                topNavigationBar
                
                
                ExperienceBar(
                    currentLevel: currentLevel,
                    currentXP: currentXP,
                    xpNeeded: xpNeeded
                )
                .padding(.horizontal, 20)
                .padding(.top, 5)
                
                Spacer()
                
                
                petSection
                
                Spacer()
                
                
                moodSection
                
                Spacer()
            }
        }
        .onAppear {
            Task {
                try? await healthKitManager.requestAuthorization()
                healthKitManager.startObservingTodayData()
                
               
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                
                StreakManager.checkAndResetStreaks(context: modelContext, healthKitManager: healthKitManager)
                
                
                checkForCompletedGoals()
            }
        }
        .onDisappear {
            healthKitManager.stopObserving()
        }
        .sheet(item: $celebration) { celebrationData in
            GoalCompletionView(
                goal: celebrationData.goal,
                currentProgress: celebrationData.progress
            )
            .onAppear {
                print(" Modal appeared with: \(celebrationData.goal.goalName)")
                print("   Progress: \(celebrationData.progress)")
            }
        }
    }
   
    var petSection: some View {
        ZStack {
            
            VStack(spacing: 0) {
               
                Color(red: 0.82, green: 0.91, blue: 0.95)
                    .frame(height: 140)
                
               
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(height: 1)
                
                
                Color(red: 0.72, green: 0.58, blue: 0.42)
                    .frame(height: 120)
            }
            
            
            VStack(spacing: 0) {
                Spacer()
                
                
                AnimatedPetView(mood: currentMood, onPet: {
                    gainXP(1)
                })
                
                Spacer()
            }
        }
        .frame(height: 260)
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.horizontal, 20)
    }
   
    var topNavigationBar: some View {
        HStack {
            Button(action: {
                print("Settings tapped")
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                print("Mail tapped")
            }) {
                Image(systemName: "envelope.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
    
    var moodSection: some View {
        Text("Whiskers feels \(PetManager.getMoodText(currentMood))")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.bottom, 20)
    }

    var backgroundColor: some View {
        LinearGradient(
            colors: [
                Color(red: 0.7, green: 0.7, blue: 1.0),
                           Color(red: 0.8, green: 0.8, blue: 1.0),  
                           Color(red: 0.9, green: 0.9, blue: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var currentMood: PetMood {
        return PetManager.calculateMood(
            steps: healthKitManager.todaySteps,
            sleepHours: healthKitManager.todaySleepHours,
            exerciseMinutes: healthKitManager.todayExerciseMinutes,
            heartRate: healthKitManager.todayHeartRateAvg
        )
    }

    func checkForCompletedGoals() {
        print(" Starting goal completion check...")
        
        CompletionTracker.shared.checkAndResetIfNewDay()
        
        let descriptor = FetchDescriptor<HealthGoal>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        guard let goals = try? modelContext.fetch(descriptor) else {
            print(" Could not fetch goals")
            return
        }
        
        print(" Checking \(goals.count) goals for completion...")
        
        for goal in goals {
            let goalID = goal.id.hashValue.description
            
            if CompletionTracker.shared.hasBeenCelebrated(goalID: goalID) {
                print("   ✓ \(goal.goalName) - Already celebrated today")
                continue
            }
            
            let progress = GoalManager.calculateProgress(goal: goal, healthKitManager: healthKitManager)
            let isCompleted = GoalManager.isGoalCompleted(current: progress, target: goal.trackableGoal)
            
            print("    \(goal.goalName): \(progress)/\(goal.trackableGoal) - Completed: \(isCompleted)")
            
            if isCompleted {
                let isNewCompletion = isNewCompletionForPeriod(goal: goal)
                
                print("   ✓ Goal completed. New completion for this period? \(isNewCompletion)")
                
                if isNewCompletion {
                    print("    NEW COMPLETION! Setting up celebration...")
                    
                    goal.streakCount += 1
                    goal.lastCompleted = Date()
                    
                    do {
                        try modelContext.save()
                        print("    Saved streak: \(goal.streakCount)")
                    } catch {
                        print("    Error saving: \(error)")
                    }
                    
                    if !CompletionTracker.shared.hasBeenCelebrated(goalID: goalID) {
                        CompletionTracker.shared.markAsCelebrated(goalID: goalID)
                        
                        let celebrationData = CelebrationData(goal: goal, progress: progress)
                        
                        print("    Created celebration data for: \(goal.goalName)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            print("    Showing celebration modal...")
                            self.celebration = celebrationData
                        }
                        
                        break
                    } else {
                        print("    Already celebrated today, skipping modal")
                    }
                } else {
                    print("    Already completed in current period, no changes")
                }
            }
        }
        
        print(" Goal check complete")
    }
    
    func isNewCompletionForPeriod(goal: HealthGoal) -> Bool {
        guard let lastCompleted = goal.lastCompleted else {
            return true
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let period = GoalManager.TimePeriod(rawValue: goal.period) ?? .day
        
        switch period {
        case .day:
            return !calendar.isDate(lastCompleted, inSameDayAs: now)
            
        case .week:
            let lastWeek = calendar.component(.weekOfYear, from: lastCompleted)
            let currentWeek = calendar.component(.weekOfYear, from: now)
            let lastYear = calendar.component(.year, from: lastCompleted)
            let currentYear = calendar.component(.year, from: now)
            return lastWeek != currentWeek || lastYear != currentYear
            
        case .month:
            let lastMonth = calendar.component(.month, from: lastCompleted)
            let currentMonth = calendar.component(.month, from: now)
            let lastYear = calendar.component(.year, from: lastCompleted)
            let currentYear = calendar.component(.year, from: now)
            return lastMonth != currentMonth || lastYear != currentYear
        }
    }
    
    
    func gainXP(_ amount: Int) {
        currentXP += amount
        
        // Check for level up
        if currentXP >= xpNeeded {
            levelUp()
        }
        
        print("📈 Gained \(amount) XP! (\(currentXP)/\(xpNeeded))")
    }
    
    func levelUp() {
        currentLevel += 1
        currentXP = currentXP - xpNeeded
        xpNeeded = calculateXPNeeded(for: currentLevel)
        
      
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        
        print(" LEVEL UP! Now level \(currentLevel)")
        print(" Next level needs \(xpNeeded) XP")
    }
    
    func calculateXPNeeded(for level: Int) -> Int {
        
        return 100 * level
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [HealthGoal.self, UserProfile.self, Pet.self, CheckIn.self, DailyHealthData.self])
}
