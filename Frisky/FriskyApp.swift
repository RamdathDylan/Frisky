import SwiftUI
import SwiftData

@main
struct FriskyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            Pet.self,
            DailyHealthData.self,
            HealthGoal.self,
            CheckIn.self
        ])
    }
}
