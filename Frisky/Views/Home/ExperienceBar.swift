import SwiftUI

struct ExperienceBar: View {
    let currentLevel: Int
    let currentXP: Int
    let xpNeeded: Int
    
    var progress: Double {
        guard xpNeeded > 0 else { return 0 }
        return Double(currentXP) / Double(xpNeeded)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            
            HStack {
                Text("Level \(currentLevel)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(currentXP) / \(xpNeeded) XP")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 12)
                    
                   
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.cyan
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    
                   
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

#Preview {
    ZStack {
        Color(red: 0.8, green: 0.8, blue: 1.0) 
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            ExperienceBar(currentLevel: 1, currentXP: 0, xpNeeded: 100)
            ExperienceBar(currentLevel: 2, currentXP: 45, xpNeeded: 100)
            ExperienceBar(currentLevel: 5, currentXP: 80, xpNeeded: 100)
            ExperienceBar(currentLevel: 10, currentXP: 100, xpNeeded: 100)
        }
        .padding()
    }
}
