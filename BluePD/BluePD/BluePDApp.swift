import SwiftUI

@main
struct BluePDApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @Environment(\.scenePhase) private var scenePhase
    @State private var isUnlocked = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !isLoggedIn {
                    LoginView()
                } else if !isUnlocked {
                    LockView(isUnlocked: $isUnlocked)
                } else {
                    ContentView()
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    isUnlocked = false   // 🔒 Locks app when closed/backgrounded
                }
            }
        }
    }
}
