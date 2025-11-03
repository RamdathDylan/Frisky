import SwiftUI

struct GoalsView: View {
    var body: some View {
        ZStack {
            Color.cyan.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                Text("Goals")
        
                Text("work in progress")
            }
        }
    }
}

#Preview {
    GoalsView()
}
