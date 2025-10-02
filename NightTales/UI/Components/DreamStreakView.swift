//
//  DreamStreakView.swift
//  NightTales
//
//  Dream streak gamification widget
//

import SwiftUI
import SwiftData

struct DreamStreakView: View {
    let currentStreak: Int
    let longestStreak: Int
    let totalDreams: Int

    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .font(.title3)

                Text("Dream Streak")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()
            }

            // Stats
            HStack(spacing: 20) {
                // Current Streak
                streakCard(
                    value: currentStreak,
                    label: "Current",
                    icon: "flame.fill",
                    color: currentStreak > 0 ? .orange : .white.opacity(0.3)
                )

                // Longest Streak
                streakCard(
                    value: longestStreak,
                    label: "Longest",
                    icon: "star.fill",
                    color: .dreamPurple
                )

                // Total Dreams
                streakCard(
                    value: totalDreams,
                    label: "Total",
                    icon: "moon.stars.fill",
                    color: .dreamBlue
                )
            }

            // Motivation Message
            motivationMessage
        }
        .padding(20)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Streak Card

    private func streakCard(value: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)

            Text("\(value)")
                .font(.title.bold())
                .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassEffect(.clear, in: .rect(cornerRadius: 12))
    }

    // MARK: - Motivation Message

    private var motivationMessage: some View {
        HStack(spacing: 12) {
            Image(systemName: motivationIcon)
                .foregroundStyle(Color.dreamPurple)
                .font(.title3)

            Text(motivationText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(12)
        .glassEffect(.clear, in: .rect(cornerRadius: 12))
    }

    private var motivationIcon: String {
        switch currentStreak {
        case 0:
            return "moon.fill"
        case 1...2:
            return "sparkles"
        case 3...6:
            return "star.fill"
        case 7...13:
            return "flame.fill"
        default:
            return "crown.fill"
        }
    }

    private var motivationText: String {
        switch currentStreak {
        case 0:
            return "Start your dream journal journey tonight!"
        case 1:
            return "Great start! Keep going to build your streak."
        case 2:
            return "You're on a roll! 2 days in a row!"
        case 3...6:
            return "Amazing! \(currentStreak) days straight. You're building a habit!"
        case 7:
            return "🎉 One week streak! You're a dream journaling champion!"
        case 8...13:
            return "Incredible! \(currentStreak) days of consistent dream recording."
        case 14:
            return "🏆 Two weeks! You're a dream master!"
        case 15...29:
            return "Legendary! \(currentStreak) days of dedication."
        case 30:
            return "🌟 30 DAYS! You've achieved dream journal mastery!"
        default:
            return "🔥 \(currentStreak) days! You're an inspiration!"
        }
    }
}

// MARK: - Streak Calculator

@MainActor
class StreakCalculator {
    static func calculateStreak(dreams: [Dream]) -> (current: Int, longest: Int) {
        guard !dreams.isEmpty else { return (0, 0) }

        let sortedDreams = dreams.sorted { $0.date > $1.date }
        let calendar = Calendar.current

        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var lastDate: Date?

        for dream in sortedDreams {
            let dreamDay = calendar.startOfDay(for: dream.date)

            if let last = lastDate {
                let lastDay = calendar.startOfDay(for: last)
                let daysDiff = calendar.dateComponents([.day], from: dreamDay, to: lastDay).day ?? 0

                if daysDiff == 1 {
                    // Consecutive day
                    tempStreak += 1
                } else if daysDiff > 1 {
                    // Gap found
                    if tempStreak > longestStreak {
                        longestStreak = tempStreak
                    }
                    tempStreak = 1
                }
            } else {
                // First dream
                let today = calendar.startOfDay(for: Date())
                let daysDiff = calendar.dateComponents([.day], from: dreamDay, to: today).day ?? 0

                if daysDiff <= 1 {
                    // Current streak active
                    currentStreak = 1
                    tempStreak = 1
                } else {
                    tempStreak = 1
                }
            }

            lastDate = dream.date
        }

        // Check final streak
        if tempStreak > longestStreak {
            longestStreak = tempStreak
        }

        // Verify current streak
        if let firstDream = sortedDreams.first {
            let today = calendar.startOfDay(for: Date())
            let firstDay = calendar.startOfDay(for: firstDream.date)
            let daysDiff = calendar.dateComponents([.day], from: firstDay, to: today).day ?? 0

            if daysDiff <= 1 {
                currentStreak = tempStreak
            } else {
                currentStreak = 0
            }
        }

        return (currentStreak, longestStreak)
    }
}

#Preview {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        VStack {
            DreamStreakView(
                currentStreak: 7,
                longestStreak: 12,
                totalDreams: 45
            )
            .padding()
        }
    }
}
