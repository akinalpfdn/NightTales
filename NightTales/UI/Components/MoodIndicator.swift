//
//  MoodIndicator.swift
//  NightTales
//
//  Mood indicator with native iOS 26 Liquid Glass
//

import SwiftUI

struct MoodIndicator: View {
    let mood: DreamMood
    let showLabel: Bool

    init(_ mood: DreamMood, showLabel: Bool = true) {
        self.mood = mood
        self.showLabel = showLabel
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: mood.icon)
                .font(.body)
                .foregroundStyle(mood.color)

            if showLabel {
                Text(mood.rawValue.capitalized)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(.regular.tint(mood.color.opacity(0.5)), in: .capsule)
    }
}

#Preview {
    VStack(spacing: 16) {
        MoodIndicator(.pleasant)
        MoodIndicator(.neutral)
        MoodIndicator(.nightmare)
        MoodIndicator(.lucid)
        MoodIndicator(.confusing)

        HStack {
            MoodIndicator(.pleasant, showLabel: false)
            MoodIndicator(.nightmare, showLabel: false)
            MoodIndicator(.lucid, showLabel: false)
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [.black, .blue.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
