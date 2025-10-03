//
//  LaunchScreenView.swift
//  NightTales
//
//  Launch screen with mystical animation
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#0F172A"),
                    Color(hex: "#1E1B4B"),
                    Color(hex: "#312E81")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated stars
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.6))
                    .frame(width: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1...2))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }

            // Main content
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.dreamPurple.opacity(0.4),
                                    Color.dreamPurple.opacity(0)
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.8 : 0.4)

                    // Moon and stars icon
                    ZStack {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.dreamPurple, Color.dreamBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.dreamPurple.opacity(0.5), radius: 20)

                        // Sparkle animation
                        Image(systemName: "sparkles")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.dreamPink)
                            .offset(x: 40, y: -30)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                    }
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)

                // App name
                VStack(spacing: 8) {
                    Text("NightTales")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.dreamPurple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Dream Journal")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                opacity = 1.0
            }
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
