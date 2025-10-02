//
//  DreamBackground.swift
//  NightTales
//
//  Animated mystical background with stars, moon, and particles
//

import SwiftUI

struct DreamBackground: View {
    let mood: DreamMood

    @State private var animateStars = false
    @State private var animateMoon = false
    @State private var particles: [Particle] = []

    var body: some View {
        ZStack {
            // Gradient background based on mood
            backgroundGradient
                .ignoresSafeArea()

            // Moon
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.8), .white.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 120, height: 120)
                .offset(x: animateMoon ? -20 : 20, y: animateMoon ? -30 : -50)
                .blur(radius: 2)
                .animation(
                    .easeInOut(duration: 8)
                    .repeatForever(autoreverses: true),
                    value: animateMoon
                )

            // Stars
            ForEach(0..<30, id: \.self) { index in
                starView(index: index)
            }

            // Particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .blur(radius: 1)
            }
        }
        .onAppear {
            animateMoon = true
            animateStars = true
            generateParticles()
        }
    }

    private var backgroundGradient: LinearGradient {
        switch mood {
        case .pleasant:
            return LinearGradient(
                colors: [
                    Color(hex: "#1a1a2e"),
                    Color(hex: "#16213e"),
                    Color(hex: "#0f3460")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .neutral:
            return LinearGradient(
                colors: [
                    Color(hex: "#2d1b69"),
                    Color(hex: "#1e1645"),
                    Color(hex: "#0d0d1f")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nightmare:
            return LinearGradient(
                colors: [
                    Color(hex: "#1a0000"),
                    Color(hex: "#0d0000"),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .lucid:
            return LinearGradient(
                colors: [
                    Color(hex: "#0a4d68"),
                    Color(hex: "#05445e"),
                    Color(hex: "#023047")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .confusing:
            return LinearGradient(
                colors: [
                    Color(hex: "#3d2c8d"),
                    Color(hex: "#2b1f5c"),
                    Color(hex: "#1a132e")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func starView(index: Int) -> some View {
        let position = starPosition(index: index)
        let size = CGFloat.random(in: 1...3)
        let delay = Double.random(in: 0...2)

        return Circle()
            .fill(.white)
            .frame(width: size, height: size)
            .offset(x: position.x, y: position.y)
            .opacity(animateStars ? 0.3 : 1.0)
            .animation(
                .easeInOut(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: animateStars
            )
    }

    private func starPosition(index: Int) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        // Pseudo-random but consistent positions
        let x = CGFloat((index * 37) % Int(screenWidth)) - screenWidth / 2
        let y = CGFloat((index * 73) % Int(screenHeight)) - screenHeight / 2

        return CGPoint(x: x, y: y)
    }

    private func generateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        for _ in 0..<15 {
            let particle = Particle(
                x: CGFloat.random(in: -screenWidth/2...screenWidth/2),
                y: CGFloat.random(in: -screenHeight/2...screenHeight/2),
                size: CGFloat.random(in: 2...6),
                color: particleColor,
                opacity: Double.random(in: 0.1...0.4)
            )
            particles.append(particle)
        }

        // Animate particles
        withAnimation(
            .easeInOut(duration: 10)
            .repeatForever(autoreverses: true)
        ) {
            for i in particles.indices {
                particles[i].y += CGFloat.random(in: -100...100)
                particles[i].opacity = Double.random(in: 0.1...0.5)
            }
        }
    }

    private var particleColor: Color {
        switch mood {
        case .pleasant: return .blue.opacity(0.6)
        case .neutral: return .purple.opacity(0.6)
        case .nightmare: return .red.opacity(0.6)
        case .lucid: return .cyan.opacity(0.6)
        case .confusing: return .orange.opacity(0.6)
        }
    }
}

// MARK: - Particle Model
struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        DreamBackground(mood: .pleasant)
            .frame(height: 200)

        DreamBackground(mood: .nightmare)
            .frame(height: 200)

        DreamBackground(mood: .lucid)
            .frame(height: 200)
    }
}
