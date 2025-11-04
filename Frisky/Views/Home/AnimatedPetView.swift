import SwiftUI

struct AnimatedPetView: View {
    let mood: PetMood
    let onPet: (() -> Void)?
    
    @State private var currentFrame = 0
    @State private var isPetting = false
    
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
   
    init(mood: PetMood, onPet: (() -> Void)? = nil) {
        self.mood = mood
        self.onPet = onPet
    }
    
    var body: some View {
        Image(getCurrentFrameName())
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 150, height: 150)
            .scaleEffect(isPetting ? 0.95 : 1.0)
            .onReceive(timer) { _ in
                currentFrame = (currentFrame + 1) % getTotalFrames()
            }
            .onTapGesture {
                petTheCat()
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
    
    func petTheCat() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            isPetting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                isPetting = false
            }
        }
        
        print("🐾 Pet the cat!")
        

        onPet?()
    }
}

#Preview {
    ZStack {
        Color.cyan.opacity(0.2)
            .ignoresSafeArea()
        
        AnimatedPetView(mood: .happy)
    }
}
