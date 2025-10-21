import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var isReceivingHealthData: Bool {
            return healthKitManager.isAuthorized
        }

    var body: some View {
        VStack() {
            Text("Steps = \(healthKitManager.todaySteps)")
            Text("Sleep = \(healthKitManager.todaySleepHours, specifier: "%.1f") hours")
            Text("Heart Rate = \(healthKitManager.todayHeartRateAvg) BPM")
            Text("Active = \(healthKitManager.todayActiveMinutes, specifier: "%.0f") min")
            Text("Exercise = \(healthKitManager.todayExerciseMinutes, specifier: "%.0f") min")
            Text("Permission =  \(healthKitManager.isAuthorized ? "true" : "false")")
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
}

#Preview {
    ContentView()
}
