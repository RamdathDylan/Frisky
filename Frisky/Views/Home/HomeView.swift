import SwiftUI

struct HomeView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                topNavigationBar
                
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
            }
        }
        .onDisappear {
            healthKitManager.stopObserving()
        }
    }
    
    var topNavigationBar: some View {
        HStack {
            Button(action: {
                print("Settings tapped")
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                print("Mail tapped")
            }) {
                Image(systemName: "envelope.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
    
    var petSection: some View {
        VStack(spacing: 15) {
            AnimatedPetView(mood: calculatePetMood())
            
            Text("Whiskers")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
    
    var moodSection: some View {
        VStack(spacing: 5) {
            Text("Mood:")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(getMoodText(calculatePetMood()))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(getMoodColor(calculatePetMood()))
        }
        .padding(.bottom, 20)
    }
    
    var backgroundColor: some View {
        LinearGradient(
            colors: [
                Color.cyan.opacity(0.3),
                Color.blue.opacity(0.15)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    func getMoodText(_ mood: PetMood) -> String {
        switch mood {
        case .happy:
            return "Happy"
        case .neutral:
            return "Neutral"
        case .sad:
            return "Sad"
        case .tired:
            return "Tired"
        }
    }
    
    func getMoodColor(_ mood: PetMood) -> Color {
        switch mood {
        case .happy:
            return .yellow
        case .neutral:
            return .gray
        case .sad:
            return .blue
        case .tired:
            return .indigo
        }
    }
    
    func calculatePetMood() -> PetMood {
        let steps = healthKitManager.todaySteps
        let sleep = healthKitManager.todaySleepHours
        let exercise = healthKitManager.todayExerciseMinutes
        
        if sleep < 6.0 {
            return .tired
        }
        
        if steps < 2000 && exercise < 10 {
            return .sad
        }
        
        if steps >= 8000 && sleep >= 7.0 {
            return .happy
        }
        
        return .neutral
    }
}

#Preview {
    HomeView()
}
