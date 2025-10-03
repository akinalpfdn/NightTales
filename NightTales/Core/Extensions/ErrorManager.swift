//
//  ErrorManager.swift
//  NightTales
//
//  Centralized error handling and user-friendly messages
//

import Foundation

// MARK: - App Error Protocol

protocol AppError: Error {
    var title: String { get }
    var message: String { get }
    var recoverySuggestion: String? { get }
    var isRetryable: Bool { get }
}

// MARK: - Dream Error

enum DreamError: AppError {
    case emptyContent
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)

    var title: String {
        switch self {
        case .emptyContent: return "Empty Dream"
        case .saveFailed: return "Save Failed"
        case .deleteFailed: return "Delete Failed"
        case .fetchFailed: return "Load Failed"
        }
    }

    var message: String {
        switch self {
        case .emptyContent:
            return "Please write or record your dream before saving."
        case .saveFailed(let error):
            return "Could not save your dream: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Could not delete the dream: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Could not load dreams: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .emptyContent:
            return "Add some content to your dream entry and try again."
        case .saveFailed, .deleteFailed, .fetchFailed:
            return "Please try again. If the problem persists, restart the app."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .emptyContent: return false
        case .saveFailed, .deleteFailed, .fetchFailed: return true
        }
    }

    var errorDescription: String? { message }
}

// MARK: - AI Error

enum AIError: AppError {
    case modelUnavailable
    case interpretationFailed(Error)
    case symbolExtractionFailed(Error)
    case patternAnalysisFailed(Error)
    case timeout
    case safetyGuardrailsTriggered

    var title: String {
        switch self {
        case .modelUnavailable: return "AI Unavailable"
        case .interpretationFailed: return "Interpretation Failed"
        case .symbolExtractionFailed: return "Symbol Detection Failed"
        case .patternAnalysisFailed: return "Analysis Failed"
        case .timeout: return "Request Timed Out"
        case .safetyGuardrailsTriggered: return "Content Not Processed"
        }
    }

    var message: String {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available on this device or is disabled."
        case .interpretationFailed(let error):
            return "Could not interpret your dream: \(error.localizedDescription)"
        case .symbolExtractionFailed(let error):
            return "Could not extract symbols: \(error.localizedDescription)"
        case .patternAnalysisFailed(let error):
            return "Could not analyze patterns: \(error.localizedDescription)"
        case .timeout:
            return "The AI request took too long and was cancelled."
        case .safetyGuardrailsTriggered:
            return "The content could not be processed due to safety restrictions."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .modelUnavailable:
            return "Check Settings → Apple Intelligence and ensure it's enabled."
        case .interpretationFailed, .symbolExtractionFailed, .patternAnalysisFailed:
            return "Try again with different wording or content."
        case .timeout:
            return "Check your internet connection and try again."
        case .safetyGuardrailsTriggered:
            return "Try rephrasing your dream content and try again."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .modelUnavailable: return false
        case .interpretationFailed, .symbolExtractionFailed, .patternAnalysisFailed, .timeout, .safetyGuardrailsTriggered:
            return true
        }
    }

    var errorDescription: String? { message }
}

// MARK: - Voice Error

enum VoiceError: AppError {
    case microphonePermissionDenied
    case speechRecognitionPermissionDenied
    case recordingFailed(Error)
    case transcriptionFailed(Error)

    var title: String {
        switch self {
        case .microphonePermissionDenied: return "Microphone Access Needed"
        case .speechRecognitionPermissionDenied: return "Speech Recognition Needed"
        case .recordingFailed: return "Recording Failed"
        case .transcriptionFailed: return "Transcription Failed"
        }
    }

    var message: String {
        switch self {
        case .microphonePermissionDenied:
            return "NightTales needs microphone access to record your dreams."
        case .speechRecognitionPermissionDenied:
            return "NightTales needs speech recognition access to transcribe your voice."
        case .recordingFailed(let error):
            return "Could not record audio: \(error.localizedDescription)"
        case .transcriptionFailed(let error):
            return "Could not transcribe audio: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .microphonePermissionDenied, .speechRecognitionPermissionDenied:
            return "Go to Settings → NightTales and enable the required permissions."
        case .recordingFailed, .transcriptionFailed:
            return "Check your microphone and try again."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .microphonePermissionDenied, .speechRecognitionPermissionDenied: return false
        case .recordingFailed, .transcriptionFailed: return true
        }
    }

    var errorDescription: String? { message }
}

// MARK: - Data Error

enum DataError: AppError {
    case exportFailed(Error)
    case importFailed(Error)
    case corruptedData
    case storageQuotaExceeded

    var title: String {
        switch self {
        case .exportFailed: return "Export Failed"
        case .importFailed: return "Import Failed"
        case .corruptedData: return "Data Corrupted"
        case .storageQuotaExceeded: return "Storage Full"
        }
    }

    var message: String {
        switch self {
        case .exportFailed(let error):
            return "Could not export your data: \(error.localizedDescription)"
        case .importFailed(let error):
            return "Could not import data: \(error.localizedDescription)"
        case .corruptedData:
            return "The data file is corrupted or invalid."
        case .storageQuotaExceeded:
            return "Your device storage is full."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .exportFailed, .importFailed:
            return "Try again or check file permissions."
        case .corruptedData:
            return "Try importing a different backup file."
        case .storageQuotaExceeded:
            return "Free up space on your device and try again."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .exportFailed, .importFailed: return true
        case .corruptedData, .storageQuotaExceeded: return false
        }
    }

    var errorDescription: String? { message }
}

// MARK: - Error Manager

@MainActor
@Observable
class ErrorManager {
    static let shared = ErrorManager()

    var currentError: (any AppError)?
    var showError = false

    private init() {}

    func handle(_ error: any AppError) {
        currentError = error
        showError = true
        HapticManager.shared.error()
    }

    func dismiss() {
        showError = false
        currentError = nil
    }

    func retry(action: @escaping () async throws -> Void) async {
        dismiss()
        try? await action()
    }
}
