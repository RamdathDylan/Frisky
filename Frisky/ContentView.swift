import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 1
    
    var body: some View {
        ZStack {
            
            Group {
                switch selectedTab {
                case 0:
                    GoalsView()
                        .transition(.opacity)
                case 1:
                    HomeView()
                        .transition(.opacity)
                case 2:
                    RecapView()
                        .transition(.opacity)
                default:
                    HomeView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
            
          
            VStack {
                Spacer()
                customTabBar
            }
        }
    }
    
    var customTabBar: some View {
        HStack(spacing: 10) {
            TabBarButton(
                title: "Goals",
                isSelected: selectedTab == 0,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 0
                    }
                }
            )
            
            TabBarButton(
                title: "Home",
                isSelected: selectedTab == 1,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 1
                    }
                }
            )
            
            TabBarButton(
                title: "Recap",
                isSelected: selectedTab == 2,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 2
                    }
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

struct TabBarButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
          
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .bold : .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? Color.cyan : Color.clear,
                            lineWidth: isSelected ? 3 : 0
                        )
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ContentView()
}
