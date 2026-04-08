import SwiftUI

@main
struct BluePDApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    ContentView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(storeManager)
        }
    }
}
