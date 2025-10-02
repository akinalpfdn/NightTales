//
//  OnboardingView.swift
//  NightTales
//
//  3-page onboarding with mystical animations
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "moon.stars.fill",
            title: "Welcome to NightTales",
            description: "Record and interpret your dreams with the power of Apple Intelligence. Discover patterns, symbols, and deeper meanings in your nightly journeys.",
            accentColor: .dreamPurple
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "AI-Powered Insights",
            description: "Our on-device AI analyzes your dreams privately and securely. Get psychological and cultural interpretations without your data ever leaving your device.",
            accentColor: .dreamBlue
        ),
        OnboardingPage(
            icon: "chart.pie.fill",
            title: "Track Your Patterns",
            description: "Visualize recurring symbols, emotional trends, and dream patterns over time. Unlock insights about your subconscious mind.",
            accentColor: .dreamPink
        )
    ]

    var body: some View {
        ZStack {
            // Animated Background
            DreamBackground(mood: .lucid)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .padding()
                }

                Spacer()

                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 500)

                // Custom Page Indicator
                pageIndicator

                Spacer()

                // Action Button
                actionButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .animation(.spring(response: 0.4), value: currentPage)
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                    .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation {
                    currentPage += 1
                }
            } else {
                completeOnboarding()
            }
        } label: {
            HStack {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .foregroundStyle(.white)

                Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "sparkles")
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Complete Onboarding

    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 32) {
            // Icon with animation
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                page.accentColor.opacity(0.3),
                                page.accentColor.opacity(0)
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.6 : 0.9)

                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.accentColor, page.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
            }
            .padding(.top, 40)

            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

#Preview {
    OnboardingView()
}
