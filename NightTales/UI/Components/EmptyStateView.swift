//
//  EmptyStateView.swift
//  NightTales
//
//  Empty state for first-time use with moon and stars
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    @State private var animateStars = false
    @State private var animateMoon = false

    init(
        title: String = "No Dreams Yet",
        message: String = "Start recording your dreams to unlock insights and patterns",
        actionTitle: String? = "Record Your First Dream",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: .neutral)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Illustration
                ZStack {
                    // Moon
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.dreamPurple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .offset(y: animateMoon ? -10 : 0)
                        .shadow(color: Color.dreamPurple.opacity(0.5), radius: 20)

                    // Floating stars
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.title2)
                            .foregroundStyle(Color.dreamPink.opacity(0.7))
                            .offset(
                                x: starOffset(index: index).x,
                                y: starOffset(index: index).y + (animateStars ? -20 : 0)
                            )
                            .opacity(animateStars ? 0.3 : 1.0)
                            .animation(
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: animateStars
                            )
                    }
                }
                .padding(.bottom, 20)

                // Text content
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Action button
                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(actionTitle)
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
                    .padding(.top, 8)
                }

                Spacer()
            }
        }
        .onAppear {
            animateStars = true
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateMoon = true
            }
        }
    }

    private func starOffset(index: Int) -> CGPoint {
        let angles: [CGFloat] = [0, 72, 144, 216, 288]
        let angle = angles[index % 5] * .pi / 180
        let radius: CGFloat = 80

        return CGPoint(
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
    }
}

#Preview {
    EmptyStateView {
        print("Add dream tapped")
    }
}

#Preview("No Action") {
    EmptyStateView(
        title: "No Insights Yet",
        message: "Record at least 3 dreams to see patterns and insights",
        actionTitle: nil,
        action: nil
    )
}
