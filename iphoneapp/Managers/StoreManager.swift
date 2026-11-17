import SwiftUI
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var subscriptions: [Product] = []
    @Published var purchaseStatus: String = ""
    @Published var isSubscribed: Bool = false // 현재 구독 상태를 저장
    @Published var activateProduct: StoreKit.Transaction?
    @Published var selectProduct: Product?
    
    init() {
        // Start listening for transaction updates
        Task {
            await listenForTransactionUpdates()
            await checkSubscriptionStatus()
        }
    }
    
    func fetchSubscriptions() async {
        
        
        do {
            let products = try await Product.products(for: ["monthlySubscribe", "yearlySubscribe"])
            subscriptions = products
            print("Fetched subscriptions: \(products.count)")
        } catch {
            print("Failed to fetch subscriptions: \(error)")
        }
    }
    
    func purchaseSubscription(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await handleVerifiedTransaction(transaction)
                case .unverified(_, _):
                    print("Purchase verification failed!")
                }
            case .pending:
                print("Purchase pending...")
            case .userCancelled:
                print("Purchase cancelled by user.")
            @unknown default:
                print("Unknown purchase result.")
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    private func handleVerifiedTransaction(_ transaction: StoreKit.Transaction) async {
        print("Purchase successful for product: \(transaction.productID)")
        activateProduct = transaction
        await checkSubscriptionStatus()
        await transaction.finish()
    }
    
    private func listenForTransactionUpdates() async {
        for await transaction in StoreKit.Transaction.updates {
            if case .verified(let verifiedTransaction) = transaction {
                await handleVerifiedTransaction(verifiedTransaction)
            } else {
                print("Transaction not verified.")
            }
        }
    }
    
    func checkSubscriptionStatus() async {
        
        do {
            if subscriptions.isEmpty {
                await fetchSubscriptions()
            }
            
            guard !subscriptions.isEmpty else {
                isSubscribed = false
                print("No subscriptions available.")
                return
            }
            
            let uniqueSubscriptions = Dictionary(grouping: subscriptions, by: { $0.id }).compactMap { $0.value.first }
            
            print("Unique Subscriptions: \(uniqueSubscriptions.count)")
            
            var activeSubscription: Product?
            
            for subscription in uniqueSubscriptions {
                print("Checking subscription: \(subscription.displayName) with ID: \(subscription.id)")
                
                if let statuses = try await subscription.subscription?.status {
                    for status in statuses {
                        if status.state == .subscribed {
                            if let latestTransaction = await subscription.latestTransaction {
                                switch latestTransaction {
                                case .verified(let transaction):
                                    if transaction.productID == subscription.id {
                                        activateProduct = transaction
                                        activeSubscription = subscription
                                        print("ACTIVATED Subscription: \(subscription.displayName) with ID: \(subscription.id)")
                                        break
                                    } else {
                                        print("Skipping subscription \(subscription.displayName) due to ID mismatch. Expected: \(subscription.id), Found: \(transaction.productID)")
                                    }
                                case .unverified(_, let error):
                                    print("Unverified transaction for \(subscription.displayName): \(error)")
                                }
                            } else {
                                print("No latest transaction available for \(subscription.displayName)")
                            }
                        }
                    }
                } else {
                    print("No status available for \(subscription.displayName)")
                }
            }
            
            if let activeSubscription = activeSubscription {
                isSubscribed = true
                print("User is subscribed to: \(activeSubscription.displayName) with ID: \(activeSubscription.id)")
            } else {
                isSubscribed = false
                activateProduct = nil
                print("User has no active subscriptions.")
            }
            
        } catch {
            print("Failed to check subscription status: \(error)")
            isSubscribed = false
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            print("Successfully restored purchases.")
            for await transaction in StoreKit.Transaction.currentEntitlements {
                if case .verified(let verifiedTransaction) = transaction {
                    await handleVerifiedTransaction(verifiedTransaction)
                }
            }
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    func convertUTCToKST(utcDate: Date) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let components = calendar.dateComponents(in: TimeZone(identifier: "Asia/Seoul")!, from: utcDate)
        return calendar.date(from: components)
    }
    
    func guessSubscribeType(item: Product) -> SubscribeType? {
        for type in SubscribeType.allCases {
            if type.id == item.id {
                return type
            }
        }
        return nil
    }
}
