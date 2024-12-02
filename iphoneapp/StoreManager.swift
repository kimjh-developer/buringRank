//
//  StoreManager.swift
//  iphoneapp
//
//  Created by mac on 12/2/24.
//

import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var subscriptionStatus: Bool = false

    private let productIds: Set<String> = [
        "monthlySubscribe", "yearlySubscribe"
    ]


    private var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await requestProducts()
            await checkSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func requestProducts() async {
        do {
            let products = try await Product.products(for: productIds)
            self.products = products
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    await checkSubscriptionStatus()
                case .unverified:
                    print("Transaction unverified")
                }
            case .userCancelled, .pending:
                print("Purchase cancelled or pending")
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func checkSubscriptionStatus() async {
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                if productIds.contains(transaction.productID) {
                    subscriptionStatus = true
                    return
                }
            case .unverified:
                print("Unverified transaction")
            }
        }
        subscriptionStatus = false
    }

    func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if self.productIds.contains(transaction.productID) {
                        await self.checkSubscriptionStatus()
                    }
                }
            }
        }
    }
}

