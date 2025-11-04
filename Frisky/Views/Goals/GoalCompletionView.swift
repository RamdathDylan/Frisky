import SwiftUI

struct GoalCompletionView: View {
    let goal: HealthGoal
    let currentProgress: Double
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 25) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    if let uiImage = UIImage(named: "cat-excited-1") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .onAppear {
                                print(" Successfully loaded cat-excited-1 image")
                            }
                    } else {
                        VStack {
                            Text("🎉")
                                .font(.system(size: 80))
                            Text("(Image: cat-excited-1 not found)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .onAppear {
                            print(" ERROR: Could not find cat-excited-1 image in Assets!")
                        }
                    }
                }
                
                Text("Goal Achieved!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(goal.goalName)
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    Text("You completed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Text(GoalManager.formatNumber(currentProgress, type: goalType))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text(goalType.unit)
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Streak info
                HStack(spacing: 8) {
                    Text("🔥")
                        .font(.title2)
                    Text("\(goal.streakCount) day streak!")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
                
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
            .padding(.horizontal, 40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            print(" GoalCompletionView appeared")
            print("   Goal: \(goal.goalName)")
            print("   Progress: \(currentProgress)")
            print("   Streak: \(goal.streakCount)")
            animateIn()
        }
    }
    
    var goalType: GoalManager.GoalType {
        GoalManager.GoalType(rawValue: goal.habitType) ?? .steps
    }
    
    func animateIn() {
       
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.0
            opacity = 1.0
        }
    }
    
    func dismissWithAnimation() {
        withAnimation(.easeIn(duration: 0.2)) {
            scale = 0.9
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
        }
    }
}

#Preview {
    GoalCompletionView(
        goal: HealthGoal(
            goalName: "Daily Steps",
            habitType: "Steps",
            trackableGoal: 10000,
            period: "Day"
        ),
        currentProgress: 10543
    )
}
