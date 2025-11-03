import SwiftUI

struct RecapView: View {
    var body: some View {
        ZStack {
            Color.cyan.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                Text("recap")
        
                Text("work in progress")
            }
        }
    }
}

#Preview {
    RecapView()
}
