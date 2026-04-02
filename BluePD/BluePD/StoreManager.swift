import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    private let productIDs = ["com.bluepd.pro"]

    init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products:", error)
        }
    }

    func purchase() async {
        guard let product = products.first else { return }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                }
            default:
                break
            }
        } catch {
            print("Purchase failed:", error)
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    var isPro: Bool {
        purchasedProductIDs.contains("com.bluepd.pro")
    }
}
