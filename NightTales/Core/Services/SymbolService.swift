//
//  SymbolService.swift
//  NightTales
//
//  Symbol database management with SwiftData
//

import Foundation
import SwiftData

class SymbolService {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Save Symbol
    func saveSymbol(_ symbol: DreamSymbol) throws {
        modelContext.insert(symbol)
        try modelContext.save()
    }

    // MARK: - Fetch All Symbols
    func fetchAllSymbols(sortBy: SymbolSortOption = .frequencyDescending) throws -> [DreamSymbol] {
        let descriptor = FetchDescriptor<DreamSymbol>(
            sortBy: [sortDescriptor(for: sortBy)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Fetch Symbols by Category
    func fetchSymbolsByCategory(_ category: String) throws -> [DreamSymbol] {
        let predicate = #Predicate<DreamSymbol> { symbol in
            symbol.category == category
        }

        let descriptor = FetchDescriptor<DreamSymbol>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.frequency, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Get Symbol by Name
    func getSymbol(named name: String) throws -> DreamSymbol? {
        let predicate = #Predicate<DreamSymbol> { symbol in
            symbol.name.localizedStandardContains(name)
        }

        let descriptor = FetchDescriptor<DreamSymbol>(
            predicate: predicate
        )

        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Update or Create Symbol
    func updateOrCreateSymbol(name: String, category: String, meaning: String) throws -> DreamSymbol {
        // Check if symbol already exists
        if let existingSymbol = try getSymbol(named: name) {
            // Update frequency and add meaning if not exists
            existingSymbol.frequency += 1
            if !existingSymbol.meanings.contains(meaning) {
                existingSymbol.meanings.append(meaning)
            }
            try modelContext.save()
            return existingSymbol
        } else {
            // Create new symbol
            let newSymbol = DreamSymbol(
                name: name,
                category: category,
                frequency: 1,
                meanings: [meaning]
            )
            modelContext.insert(newSymbol)
            try modelContext.save()
            return newSymbol
        }
    }

    // MARK: - Get Symbol Frequency
    func getSymbolFrequency(_ symbolName: String) throws -> Int {
        if let symbol = try getSymbol(named: symbolName) {
            return symbol.frequency
        }
        return 0
    }

    // MARK: - Get Most Common Symbols
    func getMostCommonSymbols(limit: Int = 10) throws -> [DreamSymbol] {
        var descriptor = FetchDescriptor<DreamSymbol>(
            sortBy: [SortDescriptor(\.frequency, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Update Symbol Meaning
    func updateSymbolMeaning(_ symbol: DreamSymbol, culturalContext: String) throws {
        symbol.culturalContext = culturalContext
        try modelContext.save()
    }

    // MARK: - Delete Symbol
    func deleteSymbol(_ symbol: DreamSymbol) throws {
        modelContext.delete(symbol)
        try modelContext.save()
    }

    // MARK: - Get All Categories
    func getAllCategories() throws -> [String] {
        let symbols = try fetchAllSymbols()
        return Array(Set(symbols.map { $0.category })).sorted()
    }

    // MARK: - Get Symbols Count by Category
    func getSymbolsCountByCategory() throws -> [String: Int] {
        let symbols = try fetchAllSymbols()
        var counts: [String: Int] = [:]

        for symbol in symbols {
            counts[symbol.category, default: 0] += 1
        }

        return counts
    }

    // MARK: - Search Symbols
    func searchSymbols(keyword: String) throws -> [DreamSymbol] {
        let predicate = #Predicate<DreamSymbol> { symbol in
            symbol.name.localizedStandardContains(keyword)
        }

        let descriptor = FetchDescriptor<DreamSymbol>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.frequency, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Get Symbol Statistics
    func getSymbolStatistics() throws -> SymbolStatistics {
        let symbols = try fetchAllSymbols()
        let totalSymbols = symbols.count
        let mostCommon = symbols.max(by: { $0.frequency < $1.frequency })
        let categories = Set(symbols.map { $0.category }).count

        return SymbolStatistics(
            totalSymbols: totalSymbols,
            totalCategories: categories,
            mostCommonSymbol: mostCommon,
            averageFrequency: symbols.isEmpty ? 0 : Double(symbols.map { $0.frequency }.reduce(0, +)) / Double(totalSymbols)
        )
    }

    // MARK: - Private Helpers
    private func sortDescriptor(for sortOption: SymbolSortOption) -> SortDescriptor<DreamSymbol> {
        switch sortOption {
        case .nameAscending:
            return SortDescriptor(\.name, order: .forward)
        case .nameDescending:
            return SortDescriptor(\.name, order: .reverse)
        case .frequencyAscending:
            return SortDescriptor(\.frequency, order: .forward)
        case .frequencyDescending:
            return SortDescriptor(\.frequency, order: .reverse)
        }
    }
}

// MARK: - Symbol Sort Options
enum SymbolSortOption {
    case nameAscending
    case nameDescending
    case frequencyAscending
    case frequencyDescending
}

// MARK: - Symbol Statistics
struct SymbolStatistics {
    let totalSymbols: Int
    let totalCategories: Int
    let mostCommonSymbol: DreamSymbol?
    let averageFrequency: Double
}
