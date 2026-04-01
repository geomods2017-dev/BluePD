import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(
            red: 10/255,
            green: 18/255,
            blue: 32/255,
            alpha: 0.96
        )

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.65)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.65)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                CaseLawView()
            }
            .tabItem {
                Label("Case Law", systemImage: "books.vertical.fill")
            }

            NavigationStack {
                StatesView()
            }
            .tabItem {
                Label("States", systemImage: "map.fill")
            }

            NavigationStack {
                EvidenceView()
            }
            .tabItem {
                Label("Evidence", systemImage: "camera.viewfinder")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(BluePDTheme.accent)
    }
}

#Preview {
    MainTabView()
}
