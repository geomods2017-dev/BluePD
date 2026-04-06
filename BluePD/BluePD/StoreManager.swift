import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    @Published var isPro = false
    @Published var products: [Product] = []
    @Published var isLoadingProducts = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    private let productID = "com.bluepd.pro"
    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = observeTransactionUpdates()

        Task {
            await loadProducts()
            await refreshPurchasedStatus()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        errorMessage = nil

        do {
            let storeProducts = try await Product.products(for: [productID])
            products = storeProducts

            if products.isEmpty {
                errorMessage = "Unable to load the Pro upgrade right now."
            }
        } catch {
            products = []
            errorMessage = "Failed to load purchase options. Please try again."
            print("Failed to load products: \(error)")
        }

        isLoadingProducts = false
    }

    func purchase() async {
        if isPurchasing { return }

        errorMessage = nil
        isPurchasing = true
        defer { isPurchasing = false }

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
                    await transaction.finish()
                    await refreshPurchasedStatus()

                case .unverified(_, let error):
                    errorMessage = "Purchase could not be verified."
                    print("Purchase verification failed: \(error)")
                }

            case .pending:
                errorMessage = "Purchase is pending approval."

            case .userCancelled:
                break

            @unknown default:
                errorMessage = "Unknown purchase result."
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
            print("Purchase failed: \(error)")
        }
    }

    func restore() async {
        errorMessage = nil

        do {
            try await AppStore.sync()
            await refreshPurchasedStatus()
        } catch {
            errorMessage = "Restore failed. Please try again."
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

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                await MainActor.run {
                    switch result {
                    case .verified(let transaction):
                        if transaction.productID == self.productID {
                            self.isPro = true
                        }

                        Task {
                            await transaction.finish()
                            await self.refreshPurchasedStatus()
                        }

                    case .unverified(_, let error):
                        self.errorMessage = "Transaction verification failed."
                        print("Transaction update unverified: \(error)")
                    }
                }
            }
        }
    }
}
