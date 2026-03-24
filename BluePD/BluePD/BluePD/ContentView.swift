import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MirandaView()
                .tabItem {
                    Label("Miranda", systemImage: "exclamationmark.bubble")
                }

            CaseLawView()
                .tabItem {
                    Label("Case Law", systemImage: "book")
                }

            StatesView()
                .tabItem {
                    Label("States", systemImage: "map")
                }

            EvidenceView()
                .tabItem {
                    Label("Evidence", systemImage: "camera")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.blue)
    }
}
