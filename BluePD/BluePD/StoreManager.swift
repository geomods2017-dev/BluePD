import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    @Published var isPro = false
    @Published var products: [Product] = []

    private let productID = "com.bluepd.pro"

    init() {
        Task {
            await loadProducts()
            await refreshPurchasedStatus()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [productID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase() async {
        do {
            if products.isEmpty {
                await loadProducts()
            }

            guard let product = products.first(where: { $0.id == productID }) else {
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
                case .unverified(_, let error):
                    print("Purchase verification failed: \(error)")
                }

            case .pending:
                print("Purchase is pending approval.")
            case .userCancelled:
                print("User cancelled purchase.")
            @unknown default:
                print("Unknown purchase result.")
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedStatus()
        } catch {
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
}
