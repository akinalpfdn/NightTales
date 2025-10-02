//
//  LiquidGlassButton.swift
//  NightTales
//
//  Button with native iOS 26 Liquid Glass effect
//

import SwiftUI

struct LiquidGlassButton: View {
    let title: String
    let icon: String?
    let style: DreamGlassStyle
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        style: DreamGlassStyle = .mystic,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }

                Text(title)
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
        }
        .dreamGlass(style, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }
}

#Preview {
    VStack(spacing: 20) {
        LiquidGlassButton("Interpret Dream", icon: "sparkles") { }
        LiquidGlassButton("Save", icon: "checkmark", style: .calm) { }
        LiquidGlassButton("Delete", icon: "trash", style: .vivid) { }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
