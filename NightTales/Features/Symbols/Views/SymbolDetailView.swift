//
//  SymbolDetailView.swift
//  NightTales
//
//  Symbol detail screen with Liquid Glass
//

import SwiftUI

struct SymbolDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let symbol: DreamSymbol

    private var categoryColor: Color {
        switch symbol.category.lowercased() {
        case "people", "person":
            return Color.dreamPink
        case "animals", "animal":
            return Color.dreamBlue
        case "nature":
            return .cyan
        case "objects", "object":
            return Color.dreamPurple
        case "emotions", "emotion":
            return .orange
        case "places", "place":
            return .mint
        default:
            return Color.dreamIndigo
        }
    }

    private var categoryIcon: String {
        switch symbol.category.lowercased() {
        case "people", "person":
            return "person.fill"
        case "animals", "animal":
            return "pawprint.fill"
        case "nature":
            return "leaf.fill"
        case "objects", "object":
            return "cube.fill"
        case "emotions", "emotion":
            return "heart.fill"
        case "places", "place":
            return "location.fill"
        default:
            return "sparkles"
        }
    }

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: .neutral)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    header

                    // Icon + Name
                    symbolHeader

                    // Stats
                    statsSection

                    // Meanings
                    if !symbol.meanings.isEmpty {
                        meaningsSection
                    }

                    // Cultural Context
                    if let context = symbol.culturalContext {
                        culturalContextSection(context)
                    }

                    // Dreams with this symbol
                    relatedDreamsSection
                }
                .padding()
                .padding(.bottom, 50)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.clear, in: .circle)

            Spacer()
        }
    }

    // MARK: - Symbol Header
    private var symbolHeader: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: categoryIcon)
                .font(.system(size: 60))
                .foregroundStyle(categoryColor)
                .frame(width: 100, height: 100)
                .glassEffect(.regular.tint(categoryColor.opacity(0.4)), in: .circle)

            // Name
            Text(symbol.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            // Category
            Text(symbol.category.capitalized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(categoryColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(.clear.tint(categoryColor.opacity(0.3)), in: .capsule)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Frequency",
                value: "\(symbol.frequency)",
                icon: "chart.bar.fill",
                color: categoryColor
            )

            statCard(
                title: "Category",
                value: symbol.category.prefix(8) + "...",
                icon: categoryIcon,
                color: categoryColor
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Meanings Section
    private var meaningsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Symbolic Meanings")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(symbol.meanings.enumerated()), id: \.offset) { index, meaning in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(categoryColor)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(meaning)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(.lucid, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Cultural Context Section
    private func culturalContextSection(_ context: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(Color.dreamBlue)
                Text("Cultural Context")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Text(context)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Related Dreams Section
    private var relatedDreamsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Color.dreamPurple)
                Text("Dreams with this Symbol")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(symbol.frequency)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }

            Text("Tap to view dreams containing this symbol")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }
}

#Preview {
    NavigationStack {
        SymbolDetailView(
            symbol: DreamSymbol(
                name: "Water",
                category: "Nature",
                frequency: 15,
                meanings: [
                    "Emotions and feelings",
                    "The subconscious mind",
                    "Purification and cleansing",
                    "Flow and adaptability",
                    "Life and renewal"
                ],
                culturalContext: "In many cultures, water represents the flow of life and emotions. It's often associated with the subconscious mind and spiritual cleansing. Dreams of water can indicate emotional states, with calm water suggesting peace and turbulent water indicating emotional turmoil."
            )
        )
    }
}
