import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    @Published var isPro = false
    @Published var products: [Product] = []
    @Published var errorMessage: String? = nil
    @Published var isLoadingProducts = false

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
        isLoadingProducts = true
        errorMessage = nil

        do {
            let storeProducts = try await Product.products(for: [productID])
            products = storeProducts

            if products.isEmpty {
                errorMessage = "Pro upgrade is currently unavailable."
                print("No products returned for id: \(productID)")
            }
        } catch {
            products = []
            errorMessage = "Failed to load Pro upgrade."
            print("Failed to load products: \(error)")
        }

        isLoadingProducts = false
    }

    func purchase() async {
        errorMessage = nil

        do {
            if products.isEmpty {
                await loadProducts()
            }

            guard let product = products.first(where: { $0.id == productID }) else {
                errorMessage = "Pro upgrade is currently unavailable."
                print("Product not found for id: \(productID)")
                return
            }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    isPro = true
                    errorMessage = nil
                    await transaction.finish()
                    await refreshPurchasedStatus()

                case .unverified(_, let error):
                    errorMessage = "Purchase verification failed."
                    print("Purchase verification failed: \(error)")
                }

            case .pending:
                errorMessage = "Purchase is pending approval."
                print("Purchase is pending approval.")

            case .userCancelled:
                errorMessage = "Purchase cancelled."
                print("User cancelled purchase.")

            @unknown default:
                errorMessage = "Unknown purchase result."
                print("Unknown purchase result.")
            }
        } catch {
            errorMessage = "Purchase failed."
            print("Purchase failed: \(error)")
        }
    }

    func restore() async {
        errorMessage = nil

        do {
            try await AppStore.sync()
            await refreshPurchasedStatus()

            if !isPro {
                errorMessage = "No previous Pro purchase found."
            }
        } catch {
            errorMessage = "Restore failed."
            print("Restore failed: \(error)")
        }
    }

    func restorePurchases() async {
        await restore()
    }

    func refreshPurchasedStatus() async {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == productID {
                    hasPro = true
                }
            case .unverified(_, let error):
                print("Unverified entitlement: \(error)")
            }
        }

        isPro = hasPro
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                switch result {
                case .verified(let transaction):
                    if transaction.productID == self.productID {
                        await MainActor.run {
                            self.isPro = true
                            self.errorMessage = nil
                        }
                    }

                    await transaction.finish()
                    await self.refreshPurchasedStatus()

                case .unverified(_, let error):
                    await MainActor.run {
                        self.errorMessage = "Transaction verification failed."
                    }
                    print("Transaction update unverified: \(error)")
                }
            }
        }
    }
}
