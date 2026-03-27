import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationView {
                SFSTView()
            }
            .tabItem {
                Label("SFST", systemImage: "checklist")
            }

            NavigationView {
                CaseLawView()
            }
            .tabItem {
                Label("Case Law", systemImage: "book.closed")
            }

            NavigationView {
                StatesView()
            }
            .tabItem {
                Label("States", systemImage: "map")
            }

            NavigationView {
                EvidenceView()
            }
            .tabItem {
                Label("Evidence", systemImage: "camera")
            }

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}
