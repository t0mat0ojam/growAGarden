import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var leafOffset: CGFloat = 0
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // Forest gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.1),
                    Color(red: 0.2, green: 0.5, blue: 0.2),
                    Color(red: 0.1, green: 0.4, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating leaves animation
            ForEach(0..<6, id: \.self) { index in
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green.opacity(0.3))
                    .font(.title2)
                    .offset(
                        x: sin(rotationAngle + Double(index) * 0.5) * 50,
                        y: cos(rotationAngle + Double(index) * 0.7) * 30 + leafOffset
                    )
                    .animation(
                        Animation.easeInOut(duration: 3.0 + Double(index) * 0.2)
                            .repeatForever(autoreverses: true),
                        value: leafOffset
                    )
            }
            
            VStack(spacing: 40) {
                // Main logo/tree animation
                ZStack {
                    // Pulsing circle background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.green.opacity(0.3),
                                    Color.green.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(scaleEffect)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: scaleEffect
                        )
                    
                    // Central tree/plant icon
                    VStack(spacing: 8) {
                        Image(systemName: "tree.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 60, weight: .light))
                            .rotationEffect(.degrees(rotationAngle * 0.1))
                        
                        // Growing sprouts
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: "leaf")
                                    .foregroundColor(.mint)
                                    .font(.title3)
                                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(index) * 0.3),
                                        value: isAnimating
                                    )
                            }
                        }
                    }
                }
                
                // Loading text with fade animation
                VStack(spacing: 16) {
                    Text("Growing Your Garden")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        .opacity(showText ? 1 : 0)
                        .animation(
                            Animation.easeIn(duration: 1.5).delay(0.5),
                            value: showText
                        )
                    
                    // Animated dots
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.3 : 0.7)
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .opacity(showText ? 1 : 0)
                }
            }
            
            // Subtle sparkle effects
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "sparkle")
                    .foregroundColor(.yellow.opacity(0.6))
                    .font(.caption)
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...700)
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.3)
                    .opacity(isAnimating ? 0.8 : 0.2)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start all animations
        withAnimation {
            isAnimating = true
            showText = true
        }
        
        // Continuous rotation for gentle movement
        withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Scale pulsing
        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            scaleEffect = 1.3
        }
        
        // Floating leaves
        withAnimation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            leafOffset = -20
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
