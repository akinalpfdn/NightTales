//
//  Dream.swift
//  NightTales
//
//  Main dream model with SwiftData
//

import Foundation
import SwiftData

@Model
final class Dream {
    var id: UUID
    var date: Date
    var title: String
    var content: String
    var mood: DreamMood
    var symbols: [String]
    var aiInterpretation: String?
    var isLucidDream: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String = "",
        content: String = "",
        mood: DreamMood = .neutral,
        symbols: [String] = [],
        aiInterpretation: String? = nil,
        isLucidDream: Bool = false
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.symbols = symbols
        self.aiInterpretation = aiInterpretation
        self.isLucidDream = isLucidDream
    }
}
