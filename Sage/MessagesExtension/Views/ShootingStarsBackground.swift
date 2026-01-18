import SwiftUI

struct ShootingStarsBackground: View {
    // Configuration
    private let starCount = 3
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    @State private var activeStars: [StarID] = []
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Base Background (Dark/Light adaptive)
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                // Stars Layer
                ForEach(activeStars) { star in
                    ShootingStarView()
                        .position(x: star.startPoint.x, y: star.startPoint.y)
                        .offset(x: star.isAnimating ? 300 : 0, y: star.isAnimating ? 300 : 0) // Trajectory
                        .opacity(star.isAnimating ? 0 : 1) // Fade out as it moves
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.5)) {
                                // Trigger animation
                            }
                        }
                }
            }
            .onReceive(timer) { _ in
                // Randomly spawn a star
                if Bool.random() && activeStars.count < 3 {
                    spawnStar(in: proxy.size)
                }
            }
        }
    }
    
    private func spawnStar(in size: CGSize) {
        let id = StarID()
        let startX = Double.random(in: 0...(size.width - 100))
        let startY = Double.random(in: 0...(size.height - 100))
        
        var newStar = StarID(startPoint: CGPoint(x: startX, y: startY))
        activeStars.append(newStar)
        
        // Animate
        withAnimation(.easeOut(duration: 2.0)) {
            if let index = activeStars.firstIndex(where: { $0.id == id.id }) {
                activeStars[index].isAnimating = true
            }
        }
        
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            activeStars.removeAll { $0.id == id.id }
        }
    }
}

struct StarID: Identifiable {
    let id = UUID()
    var startPoint: CGPoint = .zero
    var isAnimating = false
}

struct ShootingStarView: View {
    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 4, height: 4)
                .shadow(color: .blue, radius: 4)
            
            LinearGradient(
                colors: [.blue.opacity(0.6), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 60, height: 2)
        }
        .rotationEffect(.degrees(45))
    }
}

#Preview {
    ShootingStarsBackground()
}
