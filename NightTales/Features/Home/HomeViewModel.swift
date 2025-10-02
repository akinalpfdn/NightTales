//
//  HomeViewModel.swift
//  NightTales
//
//  Home screen view model
//

import Foundation
import SwiftData

@MainActor
@Observable
class HomeViewModel {

    // MARK: - Properties
    var dreams: [Dream] = []
    var selectedMood: DreamMood?
    var searchText: String = ""
    var isLoading: Bool = false
    var sortOption: SortOption = .dateDescending
    var errorMessage: String?

    let dreamService: DreamService
    let modelContext: ModelContext

    // MARK: - Computed Properties
    var filteredDreams: [Dream] {
        var result = dreams

        // Filter by mood
        if let mood = selectedMood {
            result = result.filter { $0.mood == mood }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var isEmpty: Bool {
        dreams.isEmpty
    }

    var streakStats: (current: Int, longest: Int, total: Int) {
        let (current, longest) = StreakCalculator.calculateStreak(dreams: dreams)
        return (current, longest, dreams.count)
    }

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.dreamService = DreamService(modelContext: modelContext)
    }

    // MARK: - Load Dreams
    func loadDreams() {
        isLoading = true
        errorMessage = nil

        do {
            dreams = try dreamService.fetchDreams(sortBy: sortOption)
        } catch {
            errorMessage = "Failed to load dreams: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Filter by Mood
    func filterByMood(_ mood: DreamMood?) {
        selectedMood = mood
    }

    // MARK: - Search Dreams
    func searchDreams(_ keyword: String) {
        searchText = keyword
    }

    // MARK: - Delete Dream
    func deleteDream(_ dream: Dream) {
        do {
            try dreamService.deleteDream(dream)
            loadDreams()
        } catch {
            errorMessage = "Failed to delete dream: \(error.localizedDescription)"
        }
    }

    // MARK: - Sort Dreams
    func sortDreams(by option: SortOption) {
        sortOption = option
        loadDreams()
    }

    // MARK: - Clear Filters
    func clearFilters() {
        selectedMood = nil
        searchText = ""
    }
}
