import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MirandaView()
                .tabItem {
                    Label("Miranda", systemImage: "quote.bubble")
                }

            CaseLawView()
                .tabItem {
                    Label("Case Law", systemImage: "doc.text.magnifyingglass")
                }

            StatesView()
                .tabItem {
                    Label("States", systemImage: "building.columns")
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
    }
}
