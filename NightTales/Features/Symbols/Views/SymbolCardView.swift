//
//  SymbolCardView.swift
//  NightTales
//
//  Symbol card component with Liquid Glass
//

import SwiftUI

struct SymbolCardView: View {
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
        NavigationLink {
            SymbolDetailView(symbol: symbol)
        } label: {
            cardContent
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon + Category
            HStack {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundStyle(categoryColor)
                    .frame(width: 40, height: 40)
                    .glassEffect(.clear.tint(categoryColor.opacity(0.3)), in: .circle)

                Spacer()

                // Frequency badge
                VStack(spacing: 2) {
                    Text("\(symbol.frequency)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("times")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()

            // Symbol Name
            Text(symbol.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(2)

            // Category
            Text(symbol.category.capitalized)
                .font(.caption)
                .foregroundStyle(categoryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .glassEffect(.clear.tint(categoryColor.opacity(0.3)), in: .capsule)
        }
        .padding(16)
        .frame(height: 140)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }
}

#Preview {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            SymbolCardView(
                symbol: DreamSymbol(
                    name: "Water",
                    category: "Nature",
                    frequency: 15,
                    meanings: ["Emotions", "Subconscious"]
                )
            )

            SymbolCardView(
                symbol: DreamSymbol(
                    name: "Flying",
                    category: "Emotions",
                    frequency: 8,
                    meanings: ["Freedom", "Transcendence"]
                )
            )

            SymbolCardView(
                symbol: DreamSymbol(
                    name: "Dog",
                    category: "Animals",
                    frequency: 12,
                    meanings: ["Loyalty", "Friendship"]
                )
            )
        }
        .padding()
    }
}
