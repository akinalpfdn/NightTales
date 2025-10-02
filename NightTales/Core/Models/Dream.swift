//
//  Dream.swift
//  NightTales
//
//  Main dream model with SwiftData
//

import Foundation
import SwiftData

@Model
final class Dream: Codable {
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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, date, title, content, mood, symbols, aiInterpretation, isLucidDream
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.mood = try container.decode(DreamMood.self, forKey: .mood)
        self.symbols = try container.decode([String].self, forKey: .symbols)
        self.aiInterpretation = try container.decodeIfPresent(String.self, forKey: .aiInterpretation)
        self.isLucidDream = try container.decode(Bool.self, forKey: .isLucidDream)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(mood, forKey: .mood)
        try container.encode(symbols, forKey: .symbols)
        try container.encodeIfPresent(aiInterpretation, forKey: .aiInterpretation)
        try container.encode(isLucidDream, forKey: .isLucidDream)
    }
}
