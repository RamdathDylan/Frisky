import SwiftUI
import SwiftData

class CompletionTracker: ObservableObject {
    
    static let shared = CompletionTracker()
    
    @Published var celebratedGoals: Set<String> = []
    
    
    @Published var lastCheckDate: Date = Date()
    
    private init() {
        loadCelebratedGoals()
    }
    
    func hasBeenCelebrated(goalID: String) -> Bool {
        return celebratedGoals.contains(goalID)
    }
    
    func markAsCelebrated(goalID: String) {
        celebratedGoals.insert(goalID)
        saveCelebratedGoals()
    }
    
    func checkAndResetIfNewDay() {
        let calendar = Calendar.current
        if !calendar.isDate(lastCheckDate, inSameDayAs: Date()) {
            celebratedGoals.removeAll()
            lastCheckDate = Date()
            saveCelebratedGoals()
        }
    }
    
    private func saveCelebratedGoals() {
        UserDefaults.standard.set(Array(celebratedGoals), forKey: "celebratedGoals")
        UserDefaults.standard.set(lastCheckDate, forKey: "lastCheckDate")
    }
    
    private func loadCelebratedGoals() {
        if let saved = UserDefaults.standard.array(forKey: "celebratedGoals") as? [String] {
            celebratedGoals = Set(saved)
        }
        if let date = UserDefaults.standard.object(forKey: "lastCheckDate") as? Date {
            lastCheckDate = date
        }
        
        checkAndResetIfNewDay()
    }
}
