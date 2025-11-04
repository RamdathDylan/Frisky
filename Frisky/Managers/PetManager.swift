import Foundation
import SwiftUI


enum PetMood {
    case happy
    case neutral
    case sad
    case tired
}


class PetManager {
    
   
    static func calculateMood(
        steps: Int,
        sleepHours: Double,
        exerciseMinutes: Double,
        heartRate: Int = 0
    ) -> PetMood {
        
        // PRIORITY 1: TIRED
        // Not enough sleep is the most important factor
        // User needs rest before anything else
        if sleepHours < 6.0 {
            return .tired
        }
        
        // PRIORITY 2: SAD
        // Very low activity levels indicate user is being sedentary
        // Both steps AND exercise are low
        if steps < 2000 && exerciseMinutes < 10 {
            return .sad
        }
        
        // PRIORITY 3: HAPPY
        // Good combination of steps and sleep = healthy lifestyle!
        // User is taking care of themselves
        if steps >= 8000 && sleepHours >= 7.0 {
            return .happy
        }
        
        // DEFAULT: NEUTRAL
        // Everything else - neither great nor terrible
        // Room for improvement but not concerning
        return .neutral
    }
    
    static func getMoodText(_ mood: PetMood) -> String {
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

    static func getMoodColor(_ mood: PetMood) -> Color {
        switch mood {
        case .happy:
            return .green
        case .neutral:
            return .blue
        case .sad:
            return .orange
        case .tired:
            return .purple
        }
    }
    
}
