//
//  DreamSymbol.swift
//  NightTales
//
//  Dream symbol model for symbol tracking
//

import Foundation
import SwiftData

@Model
final class DreamSymbol: Codable {
    var id: UUID
    var name: String
    var category: String
    var frequency: Int
    var meanings: [String]
    var culturalContext: String?

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        frequency: Int = 1,
        meanings: [String] = [],
        culturalContext: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.frequency = frequency
        self.meanings = meanings
        self.culturalContext = culturalContext
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, category, frequency, meanings, culturalContext
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(String.self, forKey: .category)
        self.frequency = try container.decode(Int.self, forKey: .frequency)
        self.meanings = try container.decode([String].self, forKey: .meanings)
        self.culturalContext = try container.decodeIfPresent(String.self, forKey: .culturalContext)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(meanings, forKey: .meanings)
        try container.encodeIfPresent(culturalContext, forKey: .culturalContext)
    }
}
