import SwiftUI

struct ThoughtBubble: View {
    let text: String
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                )
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 15, height: 15)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .offset(x: -4, y: 8)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .offset(x: -8, y: 22)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                    .offset(x: -12, y: 34)
            }
            .frame(height: 40)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 221/255, green: 217/255, blue: 252/255)
            .ignoresSafeArea()
        
        VStack(spacing: 100) {
            ThoughtBubble(text: "Whiskers feels Happy")
            ThoughtBubble(text: "Whiskers feels Tired")
        }
    }
}
