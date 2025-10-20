import Foundation
import SwiftData

@Model
class CheckIn {
    var date: Date
    var mood: String
    var notes: String?
    
    init(mood: String, notes: String? = nil) {
        self.date = Date()
        self.mood = mood
        self.notes = notes
    }
}
