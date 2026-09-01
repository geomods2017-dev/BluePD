import SwiftUI

@main
struct BluePDApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var storeManager = StoreManager()
    @StateObject private var cloudSync = CloudSyncManager()

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
            .environmentObject(cloudSync)
            .task {
                await cloudSync.checkAccountStatus()
            }
        }
    }
}
