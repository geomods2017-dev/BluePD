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
                SFSTView()
            }
            .tabItem {
                Label("SFST", systemImage: "checkmark.shield")
            }

            NavigationView {
                PastReportsView()
            }
            .tabItem {
                Label("Summaries", systemImage: "doc.text")
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
