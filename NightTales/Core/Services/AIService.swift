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
    func interpretDream(content: String, mood: DreamMood, style: InterpretationStyle = .mixed) async throws -> DreamInterpretation {
        guard isAvailable else {
            throw AIServiceError.modelUnavailable
        }

        let session = LanguageModelSession()

        // Customize prompt based on interpretation style
        let styleGuidance: String
        switch style {
        case .psychological:
            styleGuidance = "Focus primarily on psychological analysis, exploring the subconscious mind, emotions, and personal growth. Briefly mention symbolism and cultural context, but emphasize the psychological perspective."
        case .cultural:
            styleGuidance = "Focus primarily on cultural symbolism and traditional meanings from various cultures. Briefly mention psychological aspects, but emphasize cultural interpretations and spiritual significance."
        case .mixed:
            styleGuidance = "Provide a balanced interpretation combining psychological analysis, symbolic meaning, and cultural context equally."
        }

        let prompt = """
        You are an expert dream interpreter combining psychology, symbolism, and cultural analysis.

        Dream Content: "\(content)"
        Emotional Tone: \(mood.rawValue)

        Interpretation Style: \(styleGuidance)

        Please provide a comprehensive interpretation as a JSON object with these EXACT keys:

        1. "psychologicalAnalysis": A single paragraph (as STRING) explaining what this dream reveals about the subconscious mind, emotions, or life situation.

        2. "symbolicMeaning": A single paragraph (as STRING) explaining what the key symbols and themes represent overall.

        3. "culturalContext": A single paragraph (as STRING) explaining how different cultures might interpret these symbols.

        4. "possibleMeanings": An array of 3-5 strings, each being a different interpretation or insight.

        IMPORTANT: psychologicalAnalysis, symbolicMeaning, and culturalContext must be STRINGS (paragraphs), NOT objects or dictionaries.

        Example format:
        {
          "psychologicalAnalysis": "This dream suggests...",
          "symbolicMeaning": "The symbols in this dream...",
          "culturalContext": "In various cultures...",
          "possibleMeanings": ["First meaning", "Second meaning", "Third meaning"]
        }
        """

        let response = try await session.respond(to: prompt)

        // Clean up response - remove markdown code blocks if present
        var cleanedContent = response.content
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove markdown code blocks
        cleanedContent = cleanedContent.replacingOccurrences(of: "```json\n", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "```json", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "\n```", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "```", with: "")
        cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)

        // Fix JSON formatting - escape newlines that aren't already escaped
        // Replace actual newlines with escaped newlines in string values
        cleanedContent = fixJSONNewlines(cleanedContent)

        print("🔍 AI Response (cleaned): \(cleanedContent.prefix(200))...")

        // Parse JSON response
        guard let data = cleanedContent.data(using: .utf8) else {
            print("❌ Failed to convert to data")
            return DreamInterpretation(
                psychologicalAnalysis: "Unable to process AI response",
                symbolicMeaning: "Please try again",
                culturalContext: "Analysis unavailable",
                possibleMeanings: []
            )
        }

        do {
            let interpretation = try JSONDecoder().decode(DreamInterpretation.self, from: data)
            print("✅ JSON parsed successfully")
            return interpretation
        } catch {
            print("❌ JSON parsing error: \(error)")
            print("Raw content: \(cleanedContent)")

            // Fallback: return raw text
            return DreamInterpretation(
                psychologicalAnalysis: cleanedContent,
                symbolicMeaning: "Raw AI response (JSON parsing failed)",
                culturalContext: "Please review the psychological analysis section",
                possibleMeanings: []
            )
        }
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
        List the main symbols from this text as a simple JSON array:

        "\(content)"

        Extract 3-8 key symbols (objects, animals, nature elements, places, emotions).
        Return ONLY a JSON array like this:
        [
          {"name": "butterfly", "category": "animals", "meaning": "transformation"},
          {"name": "garden", "category": "places", "meaning": "growth"}
        ]

        Categories: people, animals, nature, objects, emotions, places, other
        """

        let response = try await session.respond(to: prompt)

        // Clean JSON
        var cleanedContent = response.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedContent = cleanedContent.replacingOccurrences(of: "```json\n", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "```json", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "\n```", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "```", with: "")
        cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedContent = fixJSONNewlines(cleanedContent)

        print("🔍 Symbols Response: \(cleanedContent.prefix(200))...")

        // Parse JSON and convert to DreamSymbol objects
        guard let data = cleanedContent.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
            print("❌ Symbol parsing failed")
            return []
        }

        let symbols: [DreamSymbol] = jsonArray.compactMap { dict -> DreamSymbol? in
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

        print("✅ Extracted \(symbols.count) symbols: \(symbols.map { $0.name }.joined(separator: ", "))")
        return symbols
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

        // Clean JSON
        var cleanedContent = response.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedContent = cleanedContent.replacingOccurrences(of: "```json\n", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "```json", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "\n```", with: "")
        cleanedContent = cleanedContent.replacingOccurrences(of: "```", with: "")
        cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedContent = fixJSONNewlines(cleanedContent)

        print("🔍 Pattern Response: \(cleanedContent.prefix(200))...")

        // Parse JSON response
        struct PatternResponse: Codable {
            let recurringSymbols: [String]
            let emotionalTrends: [String]
            let recommendations: [String]
        }

        guard let data = cleanedContent.data(using: .utf8) else {
            print("❌ Failed to convert pattern data")
            return DreamPattern(
                recurringSymbols: [],
                emotionalTrends: ["Unable to detect patterns from current data"],
                recommendations: ["Record more dreams to identify meaningful patterns"]
            )
        }

        do {
            let patternResponse = try JSONDecoder().decode(PatternResponse.self, from: data)
            print("✅ Pattern analysis successful")
            return DreamPattern(
                recurringSymbols: patternResponse.recurringSymbols,
                emotionalTrends: patternResponse.emotionalTrends,
                recommendations: patternResponse.recommendations
            )
        } catch {
            print("❌ Pattern parsing error: \(error)")
            return DreamPattern(
                recurringSymbols: [],
                emotionalTrends: ["Unable to detect patterns from current data"],
                recommendations: ["Record more dreams to identify meaningful patterns"]
            )
        }
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

    // MARK: - Helper: Fix JSON Newlines
    private func fixJSONNewlines(_ json: String) -> String {
        var result = ""
        var inString = false
        var previousChar: Character?

        for char in json {
            // Track if we're inside a string value
            if char == "\"" && previousChar != "\\" {
                inString.toggle()
            }

            // If we're in a string and encounter a newline, escape it
            if inString && char == "\n" {
                result.append("\\n")
            } else {
                result.append(char)
            }

            previousChar = char
        }

        return result
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
