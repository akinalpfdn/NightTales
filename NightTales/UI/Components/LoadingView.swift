//
//  LoadingView.swift
//  NightTales
//
//  Loading view with crystal ball animation for AI interpretation
//

import SwiftUI

struct LoadingView: View {
    let message: String

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.3

    init(message: String = "Interpreting your dream...") {
        self.message = message
    }

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: .lucid)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Crystal ball animation
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.dreamPurple.opacity(0.4),
                                    Color.dreamBlue.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(scale)
                        .opacity(opacity)

                    // Crystal ball
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.dreamPurple.opacity(0.5),
                                    Color.dreamBlue.opacity(0.7)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .glassEffect(.clear.tint(Color.dreamPurple.opacity(0.4)), in: .circle)

                    // Inner sparkles
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.title3)
                            .foregroundStyle(Color.white.opacity(0.7))
                            .offset(
                                x: cos(rotation + Double(index) * 2.0 * .pi / 3.0) * 25,
                                y: sin(rotation + Double(index) * 2.0 * .pi / 3.0) * 25
                            )
                    }
                }
                .rotationEffect(.degrees(rotation))

                // Loading text
                VStack(spacing: 12) {
                    Text(message)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.dreamPurple)
                                .frame(width: 8, height: 8)
                                .opacity(opacity)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: opacity
                                )
                        }
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.2
                opacity = 0.6
            }
        }
    }
}

#Preview {
    LoadingView()
}

#Preview("Custom Message") {
    LoadingView(message: "Analyzing dream patterns...")
}
