//
//  LiquidGlassCard.swift
//  NightTales
//
//  Card with native iOS 26 Liquid Glass effect
//

import SwiftUI

struct LiquidGlassCard<Content: View>: View {
    let style: DreamGlassStyle
    let content: Content

    init(
        style: DreamGlassStyle = .mystic,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .dreamGlass(style, shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
    }
}

#Preview {
    LiquidGlassCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Dream")
                .font(.headline)
                .foregroundStyle(.white)

            Text("I was flying over mountains...")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)

            HStack {
                Image(systemName: "moon.stars")
                    .foregroundStyle(Color.dreamPurple)
                Text("Pleasant")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [.purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
