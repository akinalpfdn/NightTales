//
//  PaywallView.swift
//  NightTales
//
//  Premium paywall with Liquid Glass design
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = PurchaseManager.shared
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: .pleasant)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Close Button
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.clear, in: .circle)
                    }
                    .padding(.horizontal)

                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.dreamPurple)

                        Text("Unlock Your Dreams")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Get unlimited AI-powered dream interpretations")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Features
                    featuresSection

                    // Pricing Card
                    if let product = purchaseManager.premiumProduct {
                        pricingCard(product: product)
                    } else {
                        ProgressView()
                            .tint(.white)
                    }

                    // Restore Button
                    restoreButton

                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // Footer
                    Text("One-time purchase • No subscription • Lifetime access")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                }
            }

            // Loading Overlay
            if isPurchasing || isRestoring {
                LoadingView(message: isPurchasing ? "Processing..." : "Restoring...")
            }
        }
    }

    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 16) {
            featureRow(icon: "infinity", title: "Unlimited AI Interpretations", description: "No monthly limits on dream analysis")
            featureRow(icon: "brain.head.profile", title: "Advanced Pattern Analysis", description: "AI-powered insights into recurring themes")
            featureRow(icon: "paintpalette", title: "All Interpretation Styles", description: "Psychological, Cultural, and Mixed perspectives")
            featureRow(icon: "mic.fill", title: "Voice Recording", description: "Record your dreams hands-free")
            featureRow(icon: "square.and.arrow.up", title: "Export & Backup", description: "Keep your dream journal safe")
            featureRow(icon: "star.fill", title: "Future Features", description: "All upcoming updates included")
        }
        .padding(.horizontal)
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color.dreamPurple)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
        .padding(16)
        .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Pricing Card
    private func pricingCard(product: Product) -> some View {
        VStack(spacing: 16) {
            Text("Premium Lifetime Access")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(product.displayPrice)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color.dreamPurple)

            Text("One-time payment")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Button {
                Task {
                    await purchaseProduct(product)
                }
            } label: {
                HStack {
                    Image(systemName: "lock.open.fill")
                    Text("Get Premium")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .dreamGlass(.vivid, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
            .disabled(isPurchasing)
        }
        .padding(24)
        .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 24)))
        .padding(.horizontal)
    }

    // MARK: - Restore Button
    private var restoreButton: some View {
        Button {
            Task {
                await restorePurchases()
            }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .underline()
        }
        .disabled(isRestoring)
    }

    // MARK: - Purchase Product
    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil

        do {
            try await purchaseManager.purchase(product)
            // Success! Dismiss paywall
            dismiss()
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            HapticManager.shared.error()
        }

        isPurchasing = false
    }

    // MARK: - Restore Purchases
    private func restorePurchases() async {
        isRestoring = true
        errorMessage = nil

        await purchaseManager.restorePurchases()

        if purchaseManager.hasPremium {
            HapticManager.shared.success()
            dismiss()
        } else {
            errorMessage = "No purchases found to restore"
        }

        isRestoring = false
    }
}

#Preview {
    PaywallView()
}
