//
//  AIUsageManager.swift
//  NightTales
//
//  Manages free tier AI interpretation usage (3/month)
//

import Foundation

@MainActor
@Observable
class AIUsageManager {

    // MARK: - Singleton
    static let shared = AIUsageManager()

    // MARK: - Constants
    private let freeMonthlyLimit = 3

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let usageCount = "aiUsageCount"
        static let lastResetDate = "aiUsageLastResetDate"
    }

    // MARK: - Properties
    var remainingFreeInterpretations: Int {
        checkAndResetIfNeeded()
        let used = UserDefaults.standard.integer(forKey: Keys.usageCount)
        return max(0, freeMonthlyLimit - used)
    }

    var hasReachedFreeLimit: Bool {
        // If user has premium, never reached limit
        if PurchaseManager.shared.hasPremium {
            return false
        }

        checkAndResetIfNeeded()
        let used = UserDefaults.standard.integer(forKey: Keys.usageCount)
        return used >= freeMonthlyLimit
    }

    // MARK: - Init
    private init() {
        checkAndResetIfNeeded()
    }

    // MARK: - Check if Can Use AI
    func canUseAI() -> Bool {
        // Premium users always can
        if PurchaseManager.shared.hasPremium {
            return true
        }

        // Check free tier limit
        return !hasReachedFreeLimit
    }

    // MARK: - Record Usage
    func recordUsage() {
        // Don't record for premium users
        guard !PurchaseManager.shared.hasPremium else {
            return
        }

        checkAndResetIfNeeded()

        let currentCount = UserDefaults.standard.integer(forKey: Keys.usageCount)
        UserDefaults.standard.set(currentCount + 1, forKey: Keys.usageCount)

        print("📊 AI Usage: \(currentCount + 1)/\(freeMonthlyLimit) this month")
    }

    // MARK: - Check and Reset Monthly
    private func checkAndResetIfNeeded() {
        let now = Date()
        let calendar = Calendar.current

        // Get last reset date
        if let lastReset = UserDefaults.standard.object(forKey: Keys.lastResetDate) as? Date {
            // Check if we're in a new month
            let lastResetComponents = calendar.dateComponents([.year, .month], from: lastReset)
            let nowComponents = calendar.dateComponents([.year, .month], from: now)

            if lastResetComponents.year != nowComponents.year ||
               lastResetComponents.month != nowComponents.month {
                // New month! Reset counter
                resetUsage()
                print("🔄 Monthly AI usage reset")
            }
        } else {
            // First time setup
            UserDefaults.standard.set(now, forKey: Keys.lastResetDate)
            UserDefaults.standard.set(0, forKey: Keys.usageCount)
        }
    }

    // MARK: - Reset Usage
    private func resetUsage() {
        UserDefaults.standard.set(0, forKey: Keys.usageCount)
        UserDefaults.standard.set(Date(), forKey: Keys.lastResetDate)
    }

    // MARK: - Get Next Reset Date
    func getNextResetDate() -> Date? {
        guard let lastReset = UserDefaults.standard.object(forKey: Keys.lastResetDate) as? Date else {
            return nil
        }

        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: lastReset)
    }

    // MARK: - Debug: Reset for Testing
    #if DEBUG
    func debugReset() {
        resetUsage()
        print("🔧 DEBUG: AI usage reset")
    }
    #endif
}
