//
//  InsightsViewModel.swift
//  NightTales
//
//  Insights screen view model with pattern analysis
//

import Foundation
import SwiftData

@MainActor
@Observable
class InsightsViewModel {

    // MARK: - Properties
    var monthlyData: [DreamMood: Int] = [:]
    var recurringSymbols: [SymbolData] = []
    var emotionalTrends: [String] = []
    var patterns: DreamPattern?
    var isGenerating: Bool = false
    var errorMessage: String?
    var selectedMonth: Date = Date()

    private let dreamService: DreamService
    private let aiService: AIService
    private let symbolService: SymbolService

    // MARK: - Computed Properties
    var hasEnoughData: Bool {
        (try? dreamService.dreamCount()) ?? 0 >= 3
    }

    var totalDreams: Int {
        (try? dreamService.dreamCount()) ?? 0
    }

    var mostCommonMood: DreamMood? {
        monthlyData.max(by: { $0.value < $1.value })?.key
    }

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.dreamService = DreamService(modelContext: modelContext)
        self.aiService = AIService.shared
        self.symbolService = SymbolService(modelContext: modelContext)
    }

    // MARK: - Load Monthly Data
    func loadMonthlyData() {
        errorMessage = nil

        do {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: selectedMonth)

            guard let year = components.year, let month = components.month else {
                return
            }

            let dreams = try dreamService.fetchDreamsForMonth(year: year, month: month)

            // Count dreams by mood
            var moodCounts: [DreamMood: Int] = [:]
            for dream in dreams {
                moodCounts[dream.mood, default: 0] += 1
            }

            monthlyData = moodCounts

        } catch {
            errorMessage = "Failed to load monthly data: \(error.localizedDescription)"
        }
    }

    // MARK: - Analyze Patterns
    func analyzePatterns() async {
        guard hasEnoughData else {
            errorMessage = "Record at least 3 dreams to see patterns"
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            // Get recent dreams for analysis
            let dreams = try dreamService.fetchRecentDreams(limit: 50)

            // Find patterns with AI
            patterns = try await aiService.findPatterns(dreams: dreams)

            // Extract emotional trends from patterns
            if let patterns = patterns {
                emotionalTrends = patterns.emotionalTrends
            }

        } catch {
            errorMessage = "Failed to analyze patterns: \(error.localizedDescription)"
        }

        isGenerating = false
    }

    // MARK: - Load Recurring Symbols
    func loadRecurringSymbols() {
        do {
            let symbols = try symbolService.getMostCommonSymbols(limit: 10)

            recurringSymbols = symbols.map { symbol in
                SymbolData(
                    name: symbol.name,
                    frequency: symbol.frequency,
                    category: symbol.category
                )
            }

        } catch {
            errorMessage = "Failed to load symbols: \(error.localizedDescription)"
        }
    }

    // MARK: - Generate Recommendations
    func generateRecommendations() async {
        guard let patterns = patterns else {
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            let recommendations = try await aiService.generateRecommendations(pattern: patterns)
            patterns.recommendations = recommendations

        } catch {
            errorMessage = "Failed to generate recommendations: \(error.localizedDescription)"
        }

        isGenerating = false
    }

    // MARK: - Change Month
    func changeMonth(offset: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: offset, to: selectedMonth) {
            selectedMonth = newDate
            loadMonthlyData()
        }
    }

    // MARK: - Refresh All Data
    func refreshAllData() async {
        loadMonthlyData()
        loadRecurringSymbols()
        await analyzePatterns()
    }
}

// MARK: - Symbol Data
struct SymbolData: Identifiable {
    let id = UUID()
    let name: String
    let frequency: Int
    let category: String
}
