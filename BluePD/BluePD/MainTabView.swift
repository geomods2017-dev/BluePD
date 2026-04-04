import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = UIColor(
            red: 5/255,
            green: 10/255,
            blue: 20/255,
            alpha: 0.98
        )

        appearance.shadowColor = UIColor.white.withAlphaComponent(0.08)

        let selectedColor = UIColor.systemBlue
        let normalColor = UIColor.white.withAlphaComponent(0.55)

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
                Label("Home", systemImage: "shield.fill")
            }

            NavigationStack {
                CaseLawView()
            }
            .tabItem {
                Label("Case Law", systemImage: "book.closed.fill")
            }

            NavigationStack {
                StatesView()
            }
            .tabItem {
                Label("Codes", systemImage: "doc.text.magnifyingglass")
            }

            NavigationStack {
                EvidenceView()
            }
            .tabItem {
                Label("Evidence", systemImage: "camera.fill")
            }

            NavigationStack {
                QuickCardsView()
            }
            .tabItem {
                Label("Quick Cards", systemImage: "rectangle.stack.text.card.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(BluePDTheme.accent)
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    MainTabView()
}
