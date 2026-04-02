import StoreKit

@MainActor
class StoreManager: ObservableObject {

    @Published var isPro = false
    private let productID = "bluepd.pro"

    func purchase() async {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else { return }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    isPro = true
                default:
                    break
                }
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restore() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID {
                isPro = true
            }
        }
    }
}
