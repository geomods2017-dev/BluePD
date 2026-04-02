import SwiftUI

@main
struct BluePDApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
                    .environmentObject(storeManager)
            } else {
                LoginView()
            }
        }
    }
}
