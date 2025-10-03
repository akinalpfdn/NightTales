//
//  NewDreamViewModel.swift
//  NightTales
//
//  New dream entry view model with AI integration
//

import Foundation
import SwiftData

@MainActor
@Observable
class NewDreamViewModel {

    // MARK: - Properties
    var title: String = ""
    var content: String = ""
    var selectedMood: DreamMood = .neutral
    var isLucidDream: Bool = false
    var isInterpreting: Bool = false
    var isRecording: Bool = false
    var interpretation: DreamInterpretation?
    var detectedSymbols: [DreamSymbol] = []
    var errorMessage: String?

    private let dreamService: DreamService
    private let aiService: AIService
    private let symbolService: SymbolService
    private let voiceService: VoiceService
    private var existingDream: Dream?

    // MARK: - Computed Properties
    var canSave: Bool {
        !content.isEmpty
    }

    var canInterpret: Bool {
        !content.isEmpty && !isInterpreting
    }

    var isEditing: Bool {
        existingDream != nil
    }

    // MARK: - Init
    init(modelContext: ModelContext, existingDream: Dream? = nil) {
        self.dreamService = DreamService(modelContext: modelContext)
        self.aiService = AIService.shared
        self.symbolService = SymbolService(modelContext: modelContext)
        self.voiceService = VoiceService.shared
        self.existingDream = existingDream

        // Populate fields if editing
        if let dream = existingDream {
            self.title = dream.title
            self.content = dream.content
            self.selectedMood = dream.mood
            self.isLucidDream = dream.isLucidDream

            // Convert symbols to DreamSymbol objects
            self.detectedSymbols = dream.symbols.map { symbolName in
                DreamSymbol(
                    name: symbolName,
                    category: "General",
                    frequency: 1,
                    meanings: [],
                    culturalContext: ""
                )
            }
        }
    }

    // MARK: - Save Dream
    func saveDream() async throws {
        guard canSave else {
            throw NewDreamError.emptyContent
        }

        if let existingDream = existingDream {
            // Update existing dream
            existingDream.title = title
            existingDream.content = content
            existingDream.mood = selectedMood
            existingDream.symbols = detectedSymbols.map { $0.name }
            existingDream.isLucidDream = isLucidDream

            if let interpretationText = interpretationText {
                existingDream.aiInterpretation = interpretationText
            }
        } else {
            // Create new dream
            let dream = Dream(
                title: title,
                content: content,
                mood: selectedMood,
                symbols: detectedSymbols.map { $0.name },
                aiInterpretation: interpretationText,
                isLucidDream: isLucidDream
            )

            try dreamService.saveDream(dream)
        }

        // Save symbols to database
        for symbol in detectedSymbols {
            try? symbolService.updateOrCreateSymbol(
                name: symbol.name,
                category: symbol.category,
                meaning: symbol.meanings.first ?? ""
            )
        }

        HapticManager.shared.success()
    }

    // MARK: - Interpret with AI
    func interpretWithAI() async {
        guard canInterpret else { return }

        isInterpreting = true
        errorMessage = nil

        do {
            // Get interpretation
            interpretation = try await aiService.interpretDream(
                content: content,
                mood: selectedMood
            )

            // Extract symbols
            detectedSymbols = try await aiService.extractSymbols(content: content)

            HapticManager.shared.success()

        } catch {
            errorMessage = "AI interpretation failed: \(error.localizedDescription)"
            interpretation = nil
            HapticManager.shared.error()
        }

        isInterpreting = false
    }

    // MARK: - Voice Recording
    func startVoiceRecording() async {
        do {
            // Request permissions
            let micPermission = await voiceService.checkMicrophonePermission()
            guard micPermission else {
                errorMessage = "Microphone permission required"
                return
            }

            let speechPermission = await voiceService.requestAuthorization()
            guard speechPermission else {
                errorMessage = "Speech recognition permission required"
                return
            }

            // Start recording
            try voiceService.startRecording()
            isRecording = true

        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    func stopVoiceRecording() {
        voiceService.stopRecording()
        isRecording = false

        // Add transcribed text to content
        if !voiceService.transcribedText.isEmpty {
            if content.isEmpty {
                content = voiceService.transcribedText
            } else {
                content += "\n\n" + voiceService.transcribedText
            }
        }

        voiceService.clearTranscription()
    }

    // MARK: - Clear Form
    func clearForm() {
        title = ""
        content = ""
        selectedMood = .neutral
        isLucidDream = false
        interpretation = nil
        detectedSymbols = []
        errorMessage = nil
    }

    // MARK: - Private Helpers
    private var interpretationText: String? {
        guard let interpretation = interpretation else { return nil }

        return """
        PSYCHOLOGICAL ANALYSIS:
        \(interpretation.psychologicalAnalysis)

        SYMBOLIC MEANING:
        \(interpretation.symbolicMeaning)

        CULTURAL CONTEXT:
        \(interpretation.culturalContext)

        POSSIBLE MEANINGS:
        \(interpretation.possibleMeanings.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))
        """
    }
}

// MARK: - Errors
enum NewDreamError: LocalizedError {
    case emptyContent
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Please enter your dream content before saving"
        case .saveFailed:
            return "Failed to save dream"
        }
    }
}
