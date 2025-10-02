//
//  SymbolCloudView.swift
//  NightTales
//
//  Symbol cloud with frequency-based sizing
//

import SwiftUI

struct SymbolCloudView: View {
    let symbols: [SymbolData]
    @State private var selectedSymbol: SymbolData?
    @State private var animationOffset: [UUID: CGFloat] = [:]

    private var maxFrequency: Int {
        symbols.map { $0.frequency }.max() ?? 1
    }

    var body: some View {
        FlowLayout(spacing: 12) {
            ForEach(symbols) { symbol in
                symbolBubble(symbol: symbol)
            }
        }
        .onAppear {
            // Initialize random offsets for floating animation
            for symbol in symbols {
                animationOffset[symbol.id] = CGFloat.random(in: -10...10)
            }

            // Start floating animation
            withAnimation(
                .easeInOut(duration: 3)
                .repeatForever(autoreverses: true)
            ) {
                for symbol in symbols {
                    animationOffset[symbol.id] = CGFloat.random(in: -15...15)
                }
            }
        }
    }

    // MARK: - Symbol Bubble
    private func symbolBubble(symbol: SymbolData) -> some View {
        let scale = symbolScale(frequency: symbol.frequency)
        let isSelected = selectedSymbol?.id == symbol.id

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedSymbol = isSelected ? nil : symbol
            }
        } label: {
            VStack(spacing: 4) {
                Text(symbol.name)
                    .font(.system(size: 12 + (scale * 8)))
                    .fontWeight(scale > 0.7 ? .bold : .medium)
                    .foregroundStyle(.white)

                Text("\(symbol.frequency)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 12 + (scale * 6))
            .padding(.vertical, 8 + (scale * 4))
        }
        .glassEffect(
            isSelected ? .regular.tint(categoryColor(symbol.category).opacity(0.6)).interactive() : .clear.tint(categoryColor(symbol.category).opacity(0.3)),
            in: .capsule
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .offset(y: animationOffset[symbol.id] ?? 0)
    }

    // MARK: - Symbol Scale
    private func symbolScale(frequency: Int) -> CGFloat {
        let normalized = CGFloat(frequency) / CGFloat(maxFrequency)
        return 0.5 + (normalized * 0.5) // Scale between 0.5 and 1.0
    }

    // MARK: - Category Color
    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "people", "person":
            return Color.dreamPink
        case "animals", "animal":
            return Color.dreamBlue
        case "nature":
            return Color.cyan
        case "objects", "object":
            return Color.dreamPurple
        case "emotions", "emotion":
            return Color.orange
        case "places", "place":
            return Color.mint
        default:
            return Color.dreamIndigo
        }
    }
}

#Preview {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        VStack {
            SymbolCloudView(
                symbols: [
                    SymbolData(name: "Water", frequency: 15, category: "nature"),
                    SymbolData(name: "Flying", frequency: 12, category: "emotions"),
                    SymbolData(name: "Mom", frequency: 8, category: "people"),
                    SymbolData(name: "Dog", frequency: 10, category: "animals"),
                    SymbolData(name: "House", frequency: 6, category: "places"),
                    SymbolData(name: "Car", frequency: 5, category: "objects"),
                    SymbolData(name: "Ocean", frequency: 9, category: "nature"),
                    SymbolData(name: "Running", frequency: 7, category: "emotions"),
                    SymbolData(name: "Forest", frequency: 11, category: "nature"),
                    SymbolData(name: "Phone", frequency: 4, category: "objects")
                ]
            )
            .padding()
            .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
            .padding()
        }
    }
}
