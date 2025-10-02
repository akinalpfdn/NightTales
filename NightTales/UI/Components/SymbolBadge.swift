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

    init(_ symbol: String, style: DreamGlassStyle = .calm) {
        self.symbol = symbol
        self.style = style
    }

    var body: some View {
        Text(symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .dreamGlass(style, shape: .capsule)
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
