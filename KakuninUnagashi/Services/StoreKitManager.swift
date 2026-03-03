import Foundation
import StoreKit

@MainActor
@Observable
final class StoreKitManager {
    private(set) var isAdRemoved = false
    private(set) var product: Product?
    private(set) var purchaseError: String?
    private var updateListenerTask: Task<Void, Never>?

    static let removeAdsProductID = "com.yourapp.kakuninunagashi.removeads"

    init() {
        updateListenerTask = Task { [weak self] in
            guard let self else { return }
            await self.listenForTransactions()
        }
        Task { [weak self] in
            await self?.loadProducts()
            await self?.updatePurchaseStatus()
        }
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.removeAdsProductID])
            product = products.first
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func purchase() async {
        guard let product else { return }
        purchaseError = nil

        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verification):
                let transaction = try Self.checkVerified(verification)
                isAdRemoved = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchaseStatus()
    }

    // MARK: - Private

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try Self.checkVerified(result)
                isAdRemoved = true
                await transaction.finish()
            } catch {
                // Transaction verification failed
            }
        }
    }

    private func updatePurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try Self.checkVerified(result)
                if transaction.productID == Self.removeAdsProductID {
                    isAdRemoved = true
                    return
                }
            } catch {
                continue
            }
        }
    }

    private nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case let .verified(safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
