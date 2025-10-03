//
//  HapticManager.swift
//  NightTales
//
//  Centralized haptic feedback management
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact - mood selection, tab change
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact - button press, card tap
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact - delete action
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success - dream saved, export complete
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning - AI interpretation taking long
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error - save failed, AI failed
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection change - scrolling through moods
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
