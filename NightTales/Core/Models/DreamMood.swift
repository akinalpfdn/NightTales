//
//  DreamMood.swift
//  NightTales
//
//  Dream mood types with icons and colors
//

import SwiftUI

enum DreamMood: String, Codable, CaseIterable {
    case pleasant
    case neutral
    case nightmare
    case lucid
    case confusing

    var icon: String {
        switch self {
        case .pleasant: return "sparkles"
        case .neutral: return "moon.stars"
        case .nightmare: return "cloud.bolt"
        case .lucid: return "eye"
        case .confusing: return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .pleasant: return .blue
        case .neutral: return .purple
        case .nightmare: return .red
        case .lucid: return .cyan
        case .confusing: return .orange
        }
    }
}
