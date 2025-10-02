//
//  SettingsViewModel.swift
//  NightTales
//
//  Settings state management
//

import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    // Settings State
    var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: "dailyReminderEnabled")
        }
    }

    var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
        }
    }

    var interpretationStyle: InterpretationStyle {
        didSet {
            UserDefaults.standard.set(interpretationStyle.rawValue, forKey: "interpretationStyle")
        }
    }

    var showDeleteConfirmation = false
    var isExporting = false
    var exportMessage: String?

    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Load saved preferences
        self.dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")

        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            self.reminderTime = savedTime
        } else {
            // Default: 8:00 AM
            let calendar = Calendar.current
            self.reminderTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        }

        if let styleRaw = UserDefaults.standard.string(forKey: "interpretationStyle"),
           let style = InterpretationStyle(rawValue: styleRaw) {
            self.interpretationStyle = style
        } else {
            self.interpretationStyle = .mixed
        }
    }

    // MARK: - Export Dreams

    @MainActor
    func exportDreams() {
        isExporting = true

        Task {
            do {
                let descriptor = FetchDescriptor<Dream>(sortBy: [SortDescriptor(\.date, order: .reverse)])
                let dreams = try modelContext.fetch(descriptor)

                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = .prettyPrinted

                let jsonData = try encoder.encode(dreams)

                // Save to documents directory
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileName = "NightTales_Export_\(Date().ISO8601Format()).json"
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)

                    try jsonData.write(to: fileURL)
                    exportMessage = "Exported \(dreams.count) dreams to Documents/\(fileName)"
                }

                isExporting = false
            } catch {
                exportMessage = "Export failed: \(error.localizedDescription)"
                isExporting = false
            }
        }
    }

    // MARK: - Delete All Data

    @MainActor
    func deleteAllData() {
        do {
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

            showDeleteConfirmation = false
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}

// MARK: - Interpretation Style

enum InterpretationStyle: String, CaseIterable, Codable {
    case psychological = "Psychological"
    case cultural = "Cultural"
    case mixed = "Mixed"

    var description: String {
        switch self {
        case .psychological:
            return "Focus on psychological meanings and personal growth"
        case .cultural:
            return "Focus on cultural symbolism and traditional meanings"
        case .mixed:
            return "Balanced approach combining both perspectives"
        }
    }

    var icon: String {
        switch self {
        case .psychological:
            return "brain.head.profile"
        case .cultural:
            return "globe.asia.australia.fill"
        case .mixed:
            return "sparkles"
        }
    }
}
