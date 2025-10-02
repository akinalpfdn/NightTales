//
//  AIService.swift
//  NightTales
//
//  AI interpretation service using Foundation Models for on-device AI
//

import Foundation
import FoundationModels

// MARK: - AI Interpretation Result
struct DreamInterpretation: Codable {
    let psychologicalAnalysis: String
    let symbolicMeaning: String
    let culturalContext: String
    let possibleMeanings: [String]
}

// MARK: - AI Service
class AIService {

    // MARK: - Singleton
    static let shared = AIService()

    private init() {}

    // Check if Apple Intelligence is available
    var isAvailable: Bool {
        SystemLanguageModel.default != nil
    }

    // MARK: - Dream Interpretation
    /// Interprets a dream with psychological and cultural analysis
    @MainActor
    func interpretDream(content: String, mood: DreamMood) async throws -> DreamInterpretation {
        guard isAvailable else {
            throw AIServiceError.modelUnavailable
        }

        let session = LanguageModelSession()

        let prompt = """
        You are an expert dream interpreter combining psychology, symbolism, and cultural analysis.

        Dream Content: "\(content)"
        Emotional Tone: \(mood.rawValue)

        Please provide a comprehensive interpretation with:
        1. Psychological Analysis: What might this dream reveal about the dreamer's subconscious mind, emotions, or current life situation?
        2. Symbolic Meaning: What do the key symbols and themes represent?
        3. Cultural Context: How might different cultural traditions interpret these symbols?
        4. Possible Meanings: 3-5 different interpretations or insights.

        Be insightful, empathetic, and thought-provoking. Format as JSON with keys: psychologicalAnalysis, symbolicMeaning, culturalContext, possibleMeanings (array of strings).
        """

        let response = try await session.respond(to: prompt)

        // Parse JSON response
        guard let data = response.content.data(using: .utf8),
              let interpretation = try? JSONDecoder().decode(DreamInterpretation.self, from: data) else {
            // Fallback if JSON parsing fails
            return DreamInterpretation(
                psychologicalAnalysis: response.content,
                symbolicMeaning: "Unable to parse symbolic meaning",
                culturalContext: "Unable to parse cultural context",
                possibleMeanings: []
            )
        }

        return interpretation
    }

    // MARK: - Symbol Extraction
    /// Extracts important symbols from dream content
    @MainActor
    func extractSymbols(content: String) async throws -> [DreamSymbol] {
        guard isAvailable else {
            throw AIServiceError.modelUnavailable
        }

        let session = LanguageModelSession()

        let prompt = """
        Analyze this dream and extract the most important symbols:

        "\(content)"

        Identify 3-8 key symbols and categorize them (e.g., people, animals, nature, objects, emotions, places).
        For each symbol, provide:
        - name: the symbol name
        - category: one of (people, animals, nature, objects, emotions, places, other)
        - meaning: brief interpretation of what this symbol typically represents

        Format as JSON array with objects containing: name, category, meaning.
        """

        let response = try await session.respond(to: prompt)

        // Parse JSON and convert to DreamSymbol objects
        guard let data = response.content.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
            return []
        }

        return jsonArray.compactMap { dict in
            guard let name = dict["name"],
                  let category = dict["category"],
                  let meaning = dict["meaning"] else {
                return nil
            }

            return DreamSymbol(
                name: name,
                category: category,
                frequency: 1,
                meanings: [meaning],
                culturalContext: nil
            )
        }
    }

    // MARK: - Pattern Finding
    /// Finds recurring patterns across multiple dreams
    @MainActor
    func findPatterns(dreams: [Dream]) async throws -> DreamPattern {
        guard isAvailable else {
            throw AIServiceError.modelUnavailable
        }

        guard !dreams.isEmpty else {
            return DreamPattern()
        }

        let session = LanguageModelSession()

        // Prepare dream summaries
        let dreamSummaries = dreams.prefix(20).enumerated().map { index, dream in
            "Dream \(index + 1) [\(dream.mood.rawValue)]: \(dream.content.prefix(200))..."
        }.joined(separator: "\n\n")

        let prompt = """
        Analyze these dreams to identify patterns:

        \(dreamSummaries)

        Identify:
        1. Recurring Symbols: Which symbols, themes, or elements appear multiple times?
        2. Emotional Trends: What emotional patterns or progressions do you notice?
        3. Recommendations: What insights or suggestions can help the dreamer understand their dreams better?

        Format as JSON with keys: recurringSymbols (array), emotionalTrends (array), recommendations (array).
        """

        let response = try await session.respond(to: prompt)

        // Parse JSON response
        struct PatternResponse: Codable {
            let recurringSymbols: [String]
            let emotionalTrends: [String]
            let recommendations: [String]
        }

        guard let data = response.content.data(using: .utf8),
              let patternResponse = try? JSONDecoder().decode(PatternResponse.self, from: data) else {
            return DreamPattern(
                recurringSymbols: [],
                emotionalTrends: ["Unable to detect patterns from current data"],
                recommendations: ["Record more dreams to identify meaningful patterns"]
            )
        }

        return DreamPattern(
            recurringSymbols: patternResponse.recurringSymbols,
            emotionalTrends: patternResponse.emotionalTrends,
            recommendations: patternResponse.recommendations
        )
    }

    // MARK: - Recommendations
    /// Generates personalized recommendations based on dream patterns
    @MainActor
    func generateRecommendations(pattern: DreamPattern) async throws -> [String] {
        guard isAvailable else {
            throw AIServiceError.modelUnavailable
        }

        let session = LanguageModelSession()

        let prompt = """
        Based on these dream patterns:

        Recurring Symbols: \(pattern.recurringSymbols.joined(separator: ", "))
        Emotional Trends: \(pattern.emotionalTrends.joined(separator: ", "))

        Provide 5 personalized, actionable recommendations for:
        - Self-reflection and awareness
        - Improving dream recall
        - Understanding deeper meanings
        - Emotional well-being

        Format as JSON array of strings.
        """

        let response = try await session.respond(to: prompt)

        guard let data = response.content.data(using: .utf8),
              let recommendations = try? JSONDecoder().decode([String].self, from: data) else {
            return pattern.recommendations
        }

        return recommendations
    }
}

// MARK: - Errors
enum AIServiceError: LocalizedError {
    case modelUnavailable
    case invalidResponse
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available on this device. Please ensure you have iOS 26+ and Apple Intelligence enabled."
        case .invalidResponse:
            return "Received an invalid response from the AI model."
        case .parsingFailed:
            return "Failed to parse AI response."
        }
    }
}
