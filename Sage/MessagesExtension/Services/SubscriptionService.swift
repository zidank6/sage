import Foundation
import StoreKit
import SwiftUI

/// Manages StoreKit 2 subscriptions and premium status
@Observable
class SubscriptionService {
    static let shared = SubscriptionService()
    
    var isPremium = false
    var products: [Product] = []
    
    // Product IDs from StoreKit Config
    private let productIDs = [
        "com.zidankazi.sage.subscription.monthly",
        "com.zidankazi.sage.subscription.yearly"
    ]
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        // Start listening for transaction updates (e.g. from other devices, renewals)
        updates = listenForTransactions()
        
        // Check initial state
        Task {
            await updateSubscriptionStatus()
            await fetchProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Core Logic
    
    /// Load available products from App Store
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: productIDs)
            await MainActor.run {
                self.products = products.sorted { $0.price < $1.price }
                print("Fetched \(products.count) products")
            }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    /// Buy a specific product
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check if the transaction is verified
            guard case .verified(let transaction) = verification else {
                return
            }
            
            // Transaction succcessful
            await transaction.finish()
            await updateSubscriptionStatus()
            
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    /// Check if user has active subscription
    func updateSubscriptionStatus() async {
        var hasActiveSubscription = false
        
        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // Check if not expired and not revoked
                if transaction.expirationDate == nil || transaction.expirationDate! > Date() {
                    hasActiveSubscription = true
                }
            }
        }
        
        await MainActor.run {
            self.isPremium = hasActiveSubscription
             print("Premium Status: \(isPremium)")
        }
    }
    
    /// Background listener for external updates
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
    }
}
