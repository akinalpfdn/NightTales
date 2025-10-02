//
//  AppColors.swift
//  NightTales
//
//  Dream themed gradients and colors for dark mode
//

import SwiftUI

extension Color {
    // Dream themed gradients
    static let moonlightGradient = LinearGradient(
        colors: [Color(hex: "#4A5568"), Color(hex: "#2D3748")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let sunsetGradient = LinearGradient(
        colors: [Color(hex: "#ED8936"), Color(hex: "#DD6B20"), Color(hex: "#C05621")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cosmicGradient = LinearGradient(
        colors: [Color(hex: "#667EEA"), Color(hex: "#764BA2"), Color(hex: "#F093FB")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let nightmareGradient = LinearGradient(
        colors: [Color(hex: "#434343"), Color(hex: "#000000")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Dark mode primary colors
    static let dreamPurple = Color(hex: "#9F7AEA")
    static let dreamBlue = Color(hex: "#4299E1")
    static let dreamPink = Color(hex: "#ED64A6")
    static let dreamIndigo = Color(hex: "#667EEA")

    // Mystical accent colors
    static let starlight = Color(hex: "#F7FAFC")
    static let moonGlow = Color(hex: "#E2E8F0")
    static let cosmicDust = Color(hex: "#CBD5E0")

    // Helper for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
