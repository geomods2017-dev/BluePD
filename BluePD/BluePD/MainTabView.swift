import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(
            red: 9/255,
            green: 16/255,
            blue: 28/255,
            alpha: 0.98
        )

        appearance.shadowColor = UIColor.white.withAlphaComponent(0.04)

        let selectedColor = UIColor.systemBlue
        let normalColor = UIColor.white.withAlphaComponent(0.58)

        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
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
                Label("Codes", systemImage: "doc.text.fill")
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
