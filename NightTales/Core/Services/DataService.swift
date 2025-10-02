//
//  DataService.swift
//  NightTales
//
//  SwiftData persistence and backup management
//

import SwiftUI
import SwiftData

@MainActor
final class DataService {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }

    // MARK: - Export JSON

    func exportToJSON() async throws -> URL {
        // Fetch all dreams
        let dreamDescriptor = FetchDescriptor<Dream>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let dreams = try modelContext.fetch(dreamDescriptor)

        // Fetch all symbols
        let symbolDescriptor = FetchDescriptor<DreamSymbol>(sortBy: [SortDescriptor(\.name)])
        let symbols = try modelContext.fetch(symbolDescriptor)

        // Fetch all patterns
        let patternDescriptor = FetchDescriptor<DreamPattern>()
        let patterns = try modelContext.fetch(patternDescriptor)

        // Create export data structure
        let exportData = ExportData(
            dreams: dreams,
            symbols: symbols,
            patterns: patterns,
            exportDate: Date(),
            version: "1.0.0"
        )

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let jsonData = try encoder.encode(exportData)

        // Save to documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DataServiceError.documentsDirectoryNotFound
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "NightTales_Backup_\(dateString).json"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        try jsonData.write(to: fileURL)

        return fileURL
    }

    // MARK: - Import JSON

    func importFromJSON(url: URL) async throws -> ImportResult {
        // Read JSON data
        let jsonData = try Data(contentsOf: url)

        // Decode
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exportData = try decoder.decode(ExportData.self, from: jsonData)

        var importedDreams = 0
        var importedSymbols = 0
        var importedPatterns = 0

        // Import dreams
        for dream in exportData.dreams {
            // Check if already exists
            let descriptor = FetchDescriptor<Dream>(
                predicate: #Predicate<Dream> { $0.id == dream.id }
            )
            let existing = try modelContext.fetch(descriptor)

            if existing.isEmpty {
                modelContext.insert(dream)
                importedDreams += 1
            }
        }

        // Import symbols
        for symbol in exportData.symbols {
            let descriptor = FetchDescriptor<DreamSymbol>(
                predicate: #Predicate<DreamSymbol> { $0.name == symbol.name }
            )
            let existing = try modelContext.fetch(descriptor)

            if existing.isEmpty {
                modelContext.insert(symbol)
                importedSymbols += 1
            }
        }

        // Import patterns
        for pattern in exportData.patterns {
            let descriptor = FetchDescriptor<DreamPattern>(
                predicate: #Predicate<DreamPattern> { $0.id == pattern.id }
            )
            let existing = try modelContext.fetch(descriptor)

            if existing.isEmpty {
                modelContext.insert(pattern)
                importedPatterns += 1
            }
        }

        // Save changes
        try modelContext.save()

        return ImportResult(
            dreamsImported: importedDreams,
            symbolsImported: importedSymbols,
            patternsImported: importedPatterns
        )
    }

    // MARK: - Delete All Data

    func deleteAllData() async throws {
        // Delete all dreams
        let dreamDescriptor = FetchDescriptor<Dream>()
        let dreams = try modelContext.fetch(dreamDescriptor)
        for dream in dreams {
            modelContext.delete(dream)
        }

        // Delete all symbols
        let symbolDescriptor = FetchDescriptor<DreamSymbol>()
        let symbols = try modelContext.fetch(symbolDescriptor)
        for symbol in symbols {
            modelContext.delete(symbol)
        }

        // Delete all patterns
        let patternDescriptor = FetchDescriptor<DreamPattern>()
        let patterns = try modelContext.fetch(patternDescriptor)
        for pattern in patterns {
            modelContext.delete(pattern)
        }

        try modelContext.save()
    }

    // MARK: - Stats

    func getDataStats() throws -> DataStats {
        let dreamDescriptor = FetchDescriptor<Dream>()
        let dreams = try modelContext.fetch(dreamDescriptor)

        let symbolDescriptor = FetchDescriptor<DreamSymbol>()
        let symbols = try modelContext.fetch(symbolDescriptor)

        let patternDescriptor = FetchDescriptor<DreamPattern>()
        let patterns = try modelContext.fetch(patternDescriptor)

        return DataStats(
            totalDreams: dreams.count,
            totalSymbols: symbols.count,
            totalPatterns: patterns.count
        )
    }
}

// MARK: - Export Data Model

struct ExportData: Codable {
    let dreams: [Dream]
    let symbols: [DreamSymbol]
    let patterns: [DreamPattern]
    let exportDate: Date
    let version: String
}

// MARK: - Import Result

struct ImportResult {
    let dreamsImported: Int
    let symbolsImported: Int
    let patternsImported: Int

    var totalImported: Int {
        dreamsImported + symbolsImported + patternsImported
    }

    var message: String {
        """
        Successfully imported:
        • \(dreamsImported) dreams
        • \(symbolsImported) symbols
        • \(patternsImported) patterns
        """
    }
}

// MARK: - Data Stats

struct DataStats {
    let totalDreams: Int
    let totalSymbols: Int
    let totalPatterns: Int
}

// MARK: - Errors

enum DataServiceError: LocalizedError {
    case documentsDirectoryNotFound
    case invalidFileFormat
    case importFailed(String)

    var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Could not access documents directory"
        case .invalidFileFormat:
            return "Invalid backup file format"
        case .importFailed(let reason):
            return "Import failed: \(reason)"
        }
    }
}
