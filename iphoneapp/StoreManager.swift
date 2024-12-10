import SwiftUI
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var subscriptions: [Product] = []
    @Published var purchaseStatus: String = ""
    @Published var isSubscribed: Bool = false // 현재 구독 상태를 저장
    @Published var activateProduct : StoreKit.Transaction?
    @Published var selectProduct : Product?
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
                    purchaseStatus = "Purchase verification failed!"
                }
            case .pending:
                purchaseStatus = "Purchase pending..."
            case .userCancelled:
                purchaseStatus = "Purchase cancelled by user."
            @unknown default:
                purchaseStatus = "Unknown purchase result."
            }
        } catch {
            print("Purchase failed: \(error)")
            purchaseStatus = "Purchase failed."
        }
    }
    
    private func handleVerifiedTransaction(_ transaction: StoreKit.Transaction) async {
        // Handle the verified transaction (e.g., unlock features)
        purchaseStatus = "Purchase successful for product: \(transaction.productID)"
        activateProduct = transaction
        await checkSubscriptionStatus()
        // Finish the transaction
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
            // 구독 목록이 비어 있으면 먼저 fetchSubscriptions 실행
            if subscriptions.isEmpty {
                await fetchSubscriptions()
            }
            
            guard !subscriptions.isEmpty else {
                isSubscribed = false
                purchaseStatus = "No subscriptions available."
                return
            }
            
            print("Subscriptions: \(subscriptions.count)")
            
            // 구독 상태 확인
            for subscription in subscriptions {
                if let subscriptionStatus = try await subscription.subscription?.status.first {
                    
                    switch subscriptionStatus.state {
                    case .subscribed:
                        isSubscribed = true
                        purchaseStatus = "User is subscribed to \(subscription.displayName)."
                        // VerificationResult<Transaction> 처리
                        if let latestTransaction = await subscription.latestTransaction {
                            switch latestTransaction {
                            case .verified(let transaction):
                                activateProduct = transaction
                                print("Verified transaction: \(transaction)")
                            case .unverified(_, let error):
                                print("Unverified transaction: \(error)")
                            }
                        } else {
                            print("No latest transaction available for \(subscription.displayName)")
                        }
                        return
                    case .expired, .revoked, .inGracePeriod, .inBillingRetryPeriod:
                        isSubscribed = false
                        purchaseStatus = "User subscription is inactive."
                    default:
                        isSubscribed = false
                        purchaseStatus = "User has no active subscription."
                    }
                } else {
                    print("Subscription status is NIL for \(subscription.displayName)")
                }
            }
            
            // 구독 상태가 없을 경우
            isSubscribed = false
            purchaseStatus = "User has no active subscription."
            
        } catch {
            print("Failed to check subscription status: \(error)")
            isSubscribed = false
            purchaseStatus = "Error checking subscription status."
        }
    }
    
    func convertUTCToKST(utcDate: Date) -> Date? {
        // 한국 시간대를 설정
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        // DateComponents로 변환 후 다시 Date로 변환
        let components = calendar.dateComponents(in: TimeZone(identifier: "Asia/Seoul")!, from: utcDate)
        return calendar.date(from: components)
    }
    
    func guessSubscribeType(item : Product)->SubscribeType?{
        for type in SubscribeType.allCases{
            if type.id == item.id{
                return type
            }
        }
        return nil
    }
}
