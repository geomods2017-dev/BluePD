import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    @Published var isPro = false
    @Published var product: Product?
    @Published var errorMessage: String?
    @Published var isLoadingProducts = false
    @Published var isPurchasing = false

    // CHANGE THIS to the exact Product ID from App Store Connect
    private let productID = "com.bluepd.pro"

    private var transactionListenerTask: Task<Void, Never>?

    init() {
        transactionListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await refreshPurchasedStatus()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func loadProducts() async {
        guard !isLoadingProducts else { return }

        isLoadingProducts = true
        errorMessage = nil

        do {
            let storeProducts = try await Product.products(for: [productID])

            print("Requested product ID: \(productID)")
            print("Store returned product IDs: \(storeProducts.map(\.id))")

            guard let matchedProduct = storeProducts.first(where: { $0.id == productID }) else {
                product = nil
                errorMessage = "Pro upgrade is unavailable. Verify the Product ID and App Store Connect setup."
                isLoadingProducts = false
                return
            }

            product = matchedProduct
        } catch {
            product = nil
            errorMessage = "Failed to load Pro upgrade: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }

        isLoadingProducts = false
    }

    func purchase() async {
        errorMessage = nil

        if product == nil {
            await loadProducts()
        }

        guard let product else {
            errorMessage = "Pro upgrade is unavailable."
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("Purchase verified for: \(transaction.productID)")
                    await transaction.finish()
                    await refreshPurchasedStatus()

                case .unverified(_, let error):
                    errorMessage = "Purchase verification failed: \(error.localizedDescription)"
                    print("Purchase verification failed: \(error)")
                }

            case .pending:
                errorMessage = "Purchase is pending approval."
                print("Purchase pending.")

            case .userCancelled:
                errorMessage = nil
                print("User cancelled purchase.")

            @unknown default:
                errorMessage = "Unknown purchase result."
                print("Unknown purchase result.")
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("Purchase failed: \(error)")
        }
    }

    func restorePurchases() async {
        errorMessage = nil

        do {
            try await AppStore.sync()
            await refreshPurchasedStatus()

            if !isPro {
                errorMessage = "No previous Pro purchase found."
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            print("Restore failed: \(error)")
        }
    }

    func refreshPurchasedStatus() async {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == productID && transaction.revocationDate == nil {
                    hasPro = true
                }

            case .unverified(_, let error):
                print("Unverified entitlement: \(error)")
            }
        }

        isPro = hasPro
        print("isPro updated to: \(isPro)")
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            guard let self else { return }

            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    print("Transaction update verified: \(transaction.productID)")

                    if transaction.productID == self.productID {
                        await transaction.finish()
                        await self.refreshPurchasedStatus()
                    } else {
                        await transaction.finish()
                    }

                case .unverified(_, let error):
                    self.errorMessage = "Transaction verification failed: \(error.localizedDescription)"
                    print("Transaction update unverified: \(error)")
                }
            }
        }
    }
}
