//
//  PurchaseManager.swift
//  NightTales
//
//  Purchase management with StoreKit 2
//

import Foundation
import StoreKit

@MainActor
@Observable
class PurchaseManager {

    // MARK: - Singleton
    static let shared = PurchaseManager()

    // MARK: - Properties
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []

    var hasPremium: Bool {
        purchasedProductIDs.contains(ProductID.premiumLifetime)
    }

    // MARK: - Product IDs
    struct ProductID {
        static let premiumLifetime = "com.nighttales.premium.lifetime"
    }

    // MARK: - Init
    private init() {
        // Start listening for transactions
        Task {
            await listenForTransactions()
        }

        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    // MARK: - Load Products
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [ProductID.premiumLifetime])
            self.products = products
            print("✅ Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Update purchased products
            await updatePurchasedProducts()

            // Finish the transaction
            await transaction.finish()

            HapticManager.shared.success()
            print("✅ Purchase successful: \(product.id)")

        case .userCancelled:
            print("⚠️ User cancelled purchase")

        case .pending:
            print("⏳ Purchase pending")

        @unknown default:
            break
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            print("✅ Purchases restored")
        } catch {
            print("❌ Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if transaction is valid
                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }

        self.purchasedProductIDs = purchasedIDs
        print("✅ Updated purchased products: \(purchasedIDs)")
    }

    // MARK: - Listen for Transactions
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)

                await updatePurchasedProducts()

                await transaction.finish()
            } catch {
                print("❌ Transaction update failed: \(error)")
            }
        }
    }

    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Premium Product
    var premiumProduct: Product? {
        products.first { $0.id == ProductID.premiumLifetime }
    }
}

// MARK: - Errors
enum PurchaseError: LocalizedError {
    case verificationFailed
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        }
    }
}
