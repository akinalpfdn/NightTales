//
//  DreamService.swift
//  NightTales
//
//  SwiftData operations for Dream management
//

import Foundation
import SwiftData

class DreamService {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Save Dream
    func saveDream(_ dream: Dream) throws {
        modelContext.insert(dream)
        try modelContext.save()
    }

    // MARK: - Fetch Dreams
    func fetchDreams(sortBy: SortOption = .dateDescending) throws -> [Dream] {
        let descriptor = FetchDescriptor<Dream>(
            sortBy: [sortDescriptor(for: sortBy)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Fetch Dreams by Date
    func fetchDreams(from startDate: Date, to endDate: Date) throws -> [Dream] {
        let predicate = #Predicate<Dream> { dream in
            dream.date >= startDate && dream.date <= endDate
        }

        let descriptor = FetchDescriptor<Dream>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Fetch Dreams by Mood
    func fetchDreams(mood: DreamMood) throws -> [Dream] {
        let predicate = #Predicate<Dream> { dream in
            dream.mood == mood
        }

        let descriptor = FetchDescriptor<Dream>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Fetch Dreams for Month
    func fetchDreamsForMonth(year: Int, month: Int) throws -> [Dream] {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let startDate = Calendar.current.date(from: components),
              let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) else {
            return []
        }

        return try fetchDreams(from: startDate, to: endDate)
    }

    // MARK: - Search Dreams
    func searchDreams(keyword: String) throws -> [Dream] {
        let predicate = #Predicate<Dream> { dream in
            dream.title.localizedStandardContains(keyword) ||
            dream.content.localizedStandardContains(keyword)
        }

        let descriptor = FetchDescriptor<Dream>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Update Dream
    func updateDream(_ dream: Dream) throws {
        try modelContext.save()
    }

    // MARK: - Delete Dream
    func deleteDream(_ dream: Dream) throws {
        modelContext.delete(dream)
        try modelContext.save()
    }

    // MARK: - Delete All Dreams
    func deleteAllDreams() throws {
        try modelContext.delete(model: Dream.self)
        try modelContext.save()
    }

    // MARK: - Count Dreams
    func dreamCount() throws -> Int {
        let descriptor = FetchDescriptor<Dream>()
        return try modelContext.fetchCount(descriptor)
    }

    // MARK: - Fetch Lucid Dreams
    func fetchLucidDreams() throws -> [Dream] {
        let predicate = #Predicate<Dream> { dream in
            dream.isLucidDream == true
        }

        let descriptor = FetchDescriptor<Dream>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Fetch Recent Dreams
    func fetchRecentDreams(limit: Int = 10) throws -> [Dream] {
        var descriptor = FetchDescriptor<Dream>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Private Helpers
    private func sortDescriptor(for sortOption: SortOption) -> SortDescriptor<Dream> {
        switch sortOption {
        case .dateAscending:
            return SortDescriptor(\.date, order: .forward)
        case .dateDescending:
            return SortDescriptor(\.date, order: .reverse)
        case .titleAscending:
            return SortDescriptor(\.title, order: .forward)
        case .titleDescending:
            return SortDescriptor(\.title, order: .reverse)
        }
    }
}

// MARK: - Sort Options
enum SortOption {
    case dateAscending
    case dateDescending
    case titleAscending
    case titleDescending
}
