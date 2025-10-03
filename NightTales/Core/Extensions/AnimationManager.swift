//
//  AnimationManager.swift
//  NightTales
//
//  Centralized animation definitions for Liquid Glass design
//

import SwiftUI

// MARK: - Animation Manager

struct AnimationManager {

    // MARK: - Mystical Animations

    /// Gentle float animation for glass elements
    static let mysticalFloat = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)

    /// Shimmer/glow animation
    static let shimmer = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)

    /// Particle float
    static let particleFloat = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)

    // MARK: - Spring Animations

    /// Bouncy spring for mood selection
    static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)

    /// Smooth spring for cards
    static let smoothSpring = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)

    /// Gentle spring for transitions
    static let gentleSpring = Animation.spring(response: 0.8, dampingFraction: 0.9, blendDuration: 0)

    // MARK: - Interactive Animations

    /// Button press
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)

    /// Card appear
    static let cardAppear = Animation.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0)

    /// Badge pop
    static let badgePop = Animation.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)
}

// MARK: - View Modifiers

/// Fade and slide from bottom
struct FadeSlideModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(AnimationManager.smoothSpring.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

/// Scale in with bounce
struct ScaleInModifier: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(AnimationManager.bouncySpring.delay(delay)) {
                    scale = 1.0
                }
            }
    }
}

/// Glow pulse animation
struct GlowPulseModifier: ViewModifier {
    let color: Color
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? 0.6 : 0.2),
                radius: isGlowing ? 20 : 10
            )
            .onAppear {
                withAnimation(AnimationManager.mysticalFloat) {
                    isGlowing = true
                }
            }
    }
}

/// Shimmer effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(AnimationManager.shimmer) {
                    phase = 300
                }
            }
    }
}

/// Typing animation for text
struct TypingTextView: View {
    let text: String
    let speed: Double
    @State private var displayedText = ""
    @State private var currentIndex = 0

    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
    }

    private func startTyping() {
        Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText.append(text[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

/// Particle float animation
struct FloatingParticle: View {
    let delay: Double
    let duration: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .fill(.white.opacity(0.3))
            .frame(width: 4, height: 4)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    offset = -50
                    opacity = 1
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Fade and slide in from bottom
    func fadeSlide(delay: Double = 0) -> some View {
        self.modifier(FadeSlideModifier(delay: delay))
    }

    /// Scale in with bounce
    func scaleIn(delay: Double = 0) -> some View {
        self.modifier(ScaleInModifier(delay: delay))
    }

    /// Glow pulse effect
    func glowPulse(color: Color = .dreamPurple) -> some View {
        self.modifier(GlowPulseModifier(color: color))
    }

    /// Shimmer effect
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }

    /// Press animation for buttons
    func pressAnimation(isPressed: Bool) -> some View {
        self.scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AnimationManager.buttonPress, value: isPressed)
    }

    /// Card hover effect
    func cardHover(isHovered: Bool) -> some View {
        self
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: Color.dreamPurple.opacity(isHovered ? 0.3 : 0.1),
                radius: isHovered ? 20 : 10
            )
            .animation(AnimationManager.smoothSpring, value: isHovered)
    }
}

// MARK: - Particle System

struct ParticleSystem: View {
    let particleCount: Int

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                FloatingParticle(
                    delay: Double(index) * 0.2,
                    duration: Double.random(in: 2...4)
                )
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -200...200)
                )
            }
        }
    }
}
