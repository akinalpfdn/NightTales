//
//  DreamSymbol.swift
//  NightTales
//
//  Dream symbol model for symbol tracking
//

import Foundation
import SwiftData

@Model
final class DreamSymbol {
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
}
