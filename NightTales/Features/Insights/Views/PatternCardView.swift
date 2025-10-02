//
//  PatternCardView.swift
//  NightTales
//
//  Pattern analysis card with expandable sections
//

import SwiftUI

struct PatternCardView: View {
    let pattern: DreamPattern
    @State private var expandedSections: Set<PatternSection> = []

    enum PatternSection: String, CaseIterable {
        case symbols = "Recurring Symbols"
        case trends = "Emotional Trends"
        case recommendations = "Recommendations"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(Color.dreamPurple)
                Text("Pattern Analysis")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text(pattern.analyzedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Divider()
                .background(.white.opacity(0.2))

            // Sections
            VStack(spacing: 12) {
                if !pattern.recurringSymbols.isEmpty {
                    sectionCard(
                        section: .symbols,
                        icon: "tag.fill",
                        color: Color.dreamPink,
                        items: pattern.recurringSymbols
                    )
                }

                if !pattern.emotionalTrends.isEmpty {
                    sectionCard(
                        section: .trends,
                        icon: "heart.fill",
                        color: Color.dreamBlue,
                        items: pattern.emotionalTrends
                    )
                }

                if !pattern.recommendations.isEmpty {
                    sectionCard(
                        section: .recommendations,
                        icon: "lightbulb.fill",
                        color: .yellow,
                        items: pattern.recommendations
                    )
                }
            }
        }
        .padding(16)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Section Card
    private func sectionCard(
        section: PatternSection,
        icon: String,
        color: Color,
        items: [String]
    ) -> some View {
        let isExpanded = expandedSections.contains(section)

        return VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Button {
                withAnimation(.spring(response: 0.3)) {
                    if isExpanded {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .frame(width: 24)

                    Text(section.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(items.count)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassEffect(.clear.tint(color.opacity(0.3)), in: .capsule)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            // Section Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 8) {
                            if section == .recommendations {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundStyle(color)
                            } else {
                                Circle()
                                    .fill(color)
                                    .frame(width: 4, height: 4)
                                    .padding(.top, 6)
                            }

                            Text(item)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.leading, 32)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .glassEffect(.clear.tint(color.opacity(0.1)), in: .rect(cornerRadius: 12))
    }
}

#Preview {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        ScrollView {
            VStack {
                PatternCardView(
                    pattern: DreamPattern(
                        recurringSymbols: [
                            "Water",
                            "Flying",
                            "Family members",
                            "Houses/buildings",
                            "Anxiety/stress"
                        ],
                        emotionalTrends: [
                            "Increasing sense of freedom in recent dreams",
                            "Recurring themes of water suggest emotional processing",
                            "Family-related dreams indicate strong connections",
                            "Flying dreams correlate with periods of confidence"
                        ],
                        recommendations: [
                            "Keep a consistent dream journal to track emotional patterns",
                            "Practice lucid dreaming techniques for more control",
                            "Reflect on water-related dreams as they may indicate emotional states",
                            "Consider meditation before sleep for clearer dream recall",
                            "Pay attention to dreams about family as they may reveal important insights"
                        ],
                        analyzedDate: Date()
                    )
                )
                .padding()
            }
        }
    }
}
