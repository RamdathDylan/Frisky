import SwiftData
import Foundation

@Model
class UserProfile {
    var name: String
    var petName: String
    var createdDate: Date
    var lastCheckIn: Date?
    var currentStreak: Int
    var longestStreak: Int
    init(name: String, petName: String) {
        self.name = name
        self.petName = petName
        self.createdDate = Date()
        self.currentStreak = 0
        self.longestStreak = 0
    }
}
