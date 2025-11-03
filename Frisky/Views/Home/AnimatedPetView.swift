import SwiftUI

struct AnimatedPetView: View {
    let mood: PetMood
    
    @State private var currentFrame = 0
    @State private var timer: Timer?
    
    var body: some View {
        Image(getCurrentFrameName())
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 150, height: 150)
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
    }
    
    private func getCurrentFrameName() -> String {
        let frameNumber = currentFrame + 1
        
        switch mood {
        case .happy:
            return "cat-happy-\(frameNumber)"
        case .neutral:
            return "cat-neutral-\(frameNumber)"
        case .sad:
            return "cat-sad-\(frameNumber)"
        case .tired:
            return "cat-tired-\(frameNumber)"
        }
    }
    
    private func getTotalFrames() -> Int {
        switch mood {
        case .happy:
            return 12
        case .neutral:
            return 10
        case .sad:
            return 8
        case .tired:
            return 8
        }
    }
    
  
    private func startAnimation() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentFrame += 1
            
            if currentFrame >= getTotalFrames() {
                currentFrame = 0
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}


enum PetMood {
    case happy
    case neutral
    case sad
    case tired
}

#Preview {
    VStack(spacing: 30) {
        Text("Happy")
        AnimatedPetView(mood: .happy)
        
        Text("Neutral")
        AnimatedPetView(mood: .neutral)
        
        Text("Sad")
        AnimatedPetView(mood: .sad)
        
        Text("Tired")
        AnimatedPetView(mood: .tired)
    }
}
