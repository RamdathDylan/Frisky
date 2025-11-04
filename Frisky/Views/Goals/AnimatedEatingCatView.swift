import SwiftUI

struct AnimatedEatingCatView: View {
    @State private var currentFrame = 1
    @State private var isPetting = false
    
    let totalFrames = 15
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("cat-eating-\(currentFrame)")
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 100, height: 100)
            .scaleEffect(isPetting ? 0.95 : 1.0)
            .onReceive(timer) { _ in
         
                currentFrame = currentFrame % totalFrames + 1
            }
            .onTapGesture {
                petTheCat()
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
        
        print(" Pet the eating cat!")
    }
}

#Preview {
    AnimatedEatingCatView()
}
