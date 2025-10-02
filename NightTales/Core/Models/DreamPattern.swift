//
//  DreamPattern.swift
//  NightTales
//
//  Dream pattern analysis model
//

import Foundation
import SwiftData

@Model
final class DreamPattern: Codable {
    var id: UUID
    var recurringSymbols: [String]
    var emotionalTrends: [String]
    var recommendations: [String]
    var analyzedDate: Date

    init(
        id: UUID = UUID(),
        recurringSymbols: [String] = [],
        emotionalTrends: [String] = [],
        recommendations: [String] = [],
        analyzedDate: Date = Date()
    ) {
        self.id = id
        self.recurringSymbols = recurringSymbols
        self.emotionalTrends = emotionalTrends
        self.recommendations = recommendations
        self.analyzedDate = analyzedDate
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, recurringSymbols, emotionalTrends, recommendations, analyzedDate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.recurringSymbols = try container.decode([String].self, forKey: .recurringSymbols)
        self.emotionalTrends = try container.decode([String].self, forKey: .emotionalTrends)
        self.recommendations = try container.decode([String].self, forKey: .recommendations)
        self.analyzedDate = try container.decode(Date.self, forKey: .analyzedDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(recurringSymbols, forKey: .recurringSymbols)
        try container.encode(emotionalTrends, forKey: .emotionalTrends)
        try container.encode(recommendations, forKey: .recommendations)
        try container.encode(analyzedDate, forKey: .analyzedDate)
    }
}
