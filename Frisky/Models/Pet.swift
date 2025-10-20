import Foundation
import SwiftData

@Model
class Pet {
    var name: String
    var sex: String
    var mood: String // "happy", "sad", "neutral", "playful", "sleepy"
    var growthLevel: Int // 1 = kitten, 2 = young, 3 = adult
    var dateOfBirth: Date
    var lastFed: Date?
    var lastPlayed: Date?
    
    init(name: String, sex: String) {
        self.name = name
        self.sex = sex
        self.mood = "neutral"
        self.growthLevel = 1 // Start as kitten
        self.dateOfBirth = Date()
    }
}
