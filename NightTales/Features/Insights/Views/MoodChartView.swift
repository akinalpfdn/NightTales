//
//  MoodChartView.swift
//  NightTales
//
//  Mood distribution chart with Liquid Glass
//

import SwiftUI

struct MoodChartView: View {
    let moodData: [DreamMood: Int]
    @State private var selectedMood: DreamMood?

    private var totalDreams: Int {
        moodData.values.reduce(0, +)
    }

    private var sortedMoods: [(mood: DreamMood, count: Int)] {
        moodData.map { (mood: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Bar Chart
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(DreamMood.allCases, id: \.self) { mood in
                    moodBar(mood: mood)
                }
            }
            .frame(height: 150)

            // Legend
            legend
        }
    }

    // MARK: - Mood Bar
    private func moodBar(mood: DreamMood) -> some View {
        let count = moodData[mood] ?? 0
        let percentage = totalDreams > 0 ? CGFloat(count) / CGFloat(totalDreams) : 0
        let isSelected = selectedMood == mood

        return VStack(spacing: 8) {
            // Count label
            if count > 0 {
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }

            // Bar
            VStack {
                Spacer(minLength: 0)

                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                mood.color.opacity(0.8),
                                mood.color.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: max(percentage * 150, count > 0 ? 20 : 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(mood.color.opacity(0.6), lineWidth: isSelected ? 2 : 0)
                    )
                    .shadow(color: mood.color.opacity(0.3), radius: isSelected ? 8 : 4)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
            }

            // Icon
            Image(systemName: mood.icon)
                .font(.caption)
                .foregroundStyle(count > 0 ? mood.color : .white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            withAnimation {
                selectedMood = selectedMood == mood ? nil : mood
            }
        }
    }

    // MARK: - Legend
    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(sortedMoods, id: \.mood) { item in
                if item.count > 0 {
                    HStack {
                        Circle()
                            .fill(item.mood.color)
                            .frame(width: 10, height: 10)

                        Text(item.mood.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))

                        Spacer()

                        Text("\(item.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text("(\(Int((Double(item.count) / Double(totalDreams)) * 100))%)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        VStack {
            MoodChartView(
                moodData: [
                    .pleasant: 15,
                    .neutral: 8,
                    .nightmare: 3,
                    .lucid: 5,
                    .confusing: 2
                ]
            )
            .padding()
            .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
            .padding()
        }
    }
}
