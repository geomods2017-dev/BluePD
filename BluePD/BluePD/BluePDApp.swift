import SwiftUI

@main
struct BluePDApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
    }
}
