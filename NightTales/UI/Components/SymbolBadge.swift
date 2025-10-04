//
//  SymbolBadge.swift
//  NightTales
//
//  Symbol badge with native iOS 26 Liquid Glass
//

import SwiftUI

struct SymbolBadge: View {
    let symbol: String
    let style: DreamGlassStyle
    let compact: Bool
    @State private var hasAppeared = false

    init(_ symbol: String, style: DreamGlassStyle = .calm, compact: Bool = false) {
        self.symbol = symbol
        self.style = style
        self.compact = compact
    }

    var body: some View {
        Text(symbol)
            .font(compact ? .caption2.weight(.medium) : .caption.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, compact ? 8 : 12)
            .padding(.vertical, compact ? 4 : 6)
            .lineLimit(1)
            .dreamGlass(style, shape: .capsule)
            .scaleEffect(hasAppeared ? 1.0 : 0.5)
            .opacity(hasAppeared ? 1.0 : 0.0)
            .onAppear {
                withAnimation(AnimationManager.badgePop.delay(Double.random(in: 0...0.3))) {
                    hasAppeared = true
                }
            }
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack {
            SymbolBadge("Water", style: .calm)
            SymbolBadge("Flying", style: .mystic)
            SymbolBadge("Animals", style: .vivid)
        }

        HStack {
            SymbolBadge("Moon")
            SymbolBadge("Stars")
            SymbolBadge("Ocean")
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
