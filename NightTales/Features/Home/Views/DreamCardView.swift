//
//  DreamCardView.swift
//  NightTales
//
//  Dream card component with Liquid Glass
//

import SwiftUI

struct DreamCardView: View {
    let dream: Dream
    let isGridLayout: Bool
    @State private var isPressed = false

    var body: some View {
        NavigationLink {
            DreamDetailView(dream: dream)
        } label: {
            cardContent
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(AnimationManager.buttonPress) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(AnimationManager.buttonPress) {
                        isPressed = false
                    }
                }
        )
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: isGridLayout ? 8 : 12) {
            // Header: Date + Mood
            HStack {
                Text(dream.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                MoodIndicator(dream.mood, showLabel: false)
            }

            // Title or first line of content
            Text(dream.title.isEmpty ? dream.content : dream.title)
                .font(isGridLayout ? .subheadline : .headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(isGridLayout ? 2 : 1)

            if !isGridLayout {
                // Content preview (only in list mode)
                Text(dream.content)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
            }

            // Symbols (max 3)
            if !dream.symbols.isEmpty {
                HStack(spacing: 6) {
                    ForEach(dream.symbols.prefix(3), id: \.self) { symbol in
                        SymbolBadge(symbol, style: .calm)
                    }

                    if dream.symbols.count > 3 {
                        Text("+\(dream.symbols.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }

            Spacer()

            // Footer: Lucid badge + interpretation status
            HStack {
                if dream.isLucidDream {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.caption2)
                        Text("Lucid")
                            .font(.caption2)
                    }
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .glassEffect(.clear.tint(.cyan.opacity(0.4)), in: .capsule)
                }

                Spacer()

                if dream.aiInterpretation != nil {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Color.dreamPurple)
                }
            }
        }
        .padding(isGridLayout ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: isGridLayout ? 180 : nil)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .shadow(
            color: Color.dreamPurple.opacity(isPressed ? 0.4 : 0.2),
            radius: isPressed ? 15 : 10
        )
    }
}

#Preview("Grid Layout") {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        VStack {
            DreamCardView(
                dream: Dream(
                    title: "Flying Over Mountains",
                    content: "I was soaring through the sky, watching the mountains below me...",
                    mood: .pleasant,
                    symbols: ["Flying", "Mountains", "Sky", "Freedom"],
                    aiInterpretation: "This dream represents...",
                    isLucidDream: true
                ),
                isGridLayout: true
            )
            .frame(width: 180)
        }
        .padding()
    }
}

#Preview("List Layout") {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        VStack {
            DreamCardView(
                dream: Dream(
                    title: "Ocean Waves",
                    content: "I was standing on a beach, watching giant waves crash against the shore. The water was crystal clear and I could see colorful fish swimming beneath the surface.",
                    mood: .pleasant,
                    symbols: ["Ocean", "Waves", "Beach"],
                    aiInterpretation: nil,
                    isLucidDream: false
                ),
                isGridLayout: false
            )

            DreamCardView(
                dream: Dream(
                    title: "",
                    content: "Running through a dark forest, being chased by shadows...",
                    mood: .nightmare,
                    symbols: ["Forest", "Darkness", "Running"],
                    aiInterpretation: "Interpreted",
                    isLucidDream: false
                ),
                isGridLayout: false
            )
        }
        .padding()
    }
}
