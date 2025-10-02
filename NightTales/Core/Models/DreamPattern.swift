//
//  DreamPattern.swift
//  NightTales
//
//  Dream pattern analysis model
//

import Foundation
import SwiftData

@Model
final class DreamPattern {
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
}
