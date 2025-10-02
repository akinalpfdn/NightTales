//
//  LiquidGlassStyles.swift
//  NightTales
//
//  Liquid Glass helpers using iOS 26 native .glassEffect() API
//

import SwiftUI

// MARK: - Dream Glass Styles
enum DreamGlassStyle {
    case mystic       // Purple tinted, interactive
    case calm         // Blue tinted, regular
    case vivid        // Pink tinted, clear
    case nightmare    // Dark tinted
    case lucid        // Cyan tinted, interactive
}

// MARK: - View Extension for Dream-themed Glass
extension View {
    /// Applies dream-themed Liquid Glass effect using native iOS 26 API
    func dreamGlass(
        _ style: DreamGlassStyle = .mystic,
        shape: AnyShape? = nil
    ) -> some View {
        Group {
            switch style {
            case .mystic:
                if let shape = shape {
                    self.glassEffect(.regular.tint(Color.dreamPurple.opacity(0.6)).interactive(), in: shape)
                } else {
                    self.glassEffect(.regular.tint(Color.dreamPurple.opacity(0.6)).interactive())
                }

            case .calm:
                if let shape = shape {
                    self.glassEffect(.regular.tint(Color.dreamBlue.opacity(0.5)), in: shape)
                } else {
                    self.glassEffect(.regular.tint(Color.dreamBlue.opacity(0.5)))
                }

            case .vivid:
                if let shape = shape {
                    self.glassEffect(.clear.tint(Color.dreamPink.opacity(0.7)).interactive(), in: shape)
                } else {
                    self.glassEffect(.clear.tint(Color.dreamPink.opacity(0.7)).interactive())
                }

            case .nightmare:
                if let shape = shape {
                    self.glassEffect(.regular.tint(Color.black.opacity(0.4)), in: shape)
                } else {
                    self.glassEffect(.regular.tint(Color.black.opacity(0.4)))
                }

            case .lucid:
                if let shape = shape {
                    self.glassEffect(.clear.tint(Color.cyan.opacity(0.6)).interactive(), in: shape)
                } else {
                    self.glassEffect(.clear.tint(Color.cyan.opacity(0.6)).interactive())
                }
            }
        }
    }
}

// MARK: - AnyShape Helper
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - Common Shapes
extension AnyShape {
    static var roundedRect: AnyShape {
        AnyShape(RoundedRectangle(cornerRadius: 16))
    }

    static var capsule: AnyShape {
        AnyShape(Capsule())
    }

    static var circle: AnyShape {
        AnyShape(Circle())
    }
}
