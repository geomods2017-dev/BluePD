import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 11/255, green: 18/255, blue: 32/255, alpha: 1.0)

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.lightGray
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            tabNavigation {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            tabNavigation {
                CaseLawView()
            }
            .tabItem {
                Label("Case Law", systemImage: "book.closed.fill")
            }

            tabNavigation {
                StatesView()
            }
            .tabItem {
                Label("States", systemImage: "map.fill")
            }

            tabNavigation {
                SFSTView()
            }
            .tabItem {
                Label("SFST", systemImage: "checkmark.shield.fill")
            }

            tabNavigation {
                PastReportsView()
            }
            .tabItem {
                Label("Summaries", systemImage: "doc.text.fill")
            }

            tabNavigation {
                EvidenceView()
            }
            .tabItem {
                Label("Evidence", systemImage: "camera.fill")
            }

            tabNavigation {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .accentColor(.blue)
        .background(Color(red: 7/255, green: 12/255, blue: 24/255).ignoresSafeArea())
    }

    @ViewBuilder
    private func tabNavigation<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            content()
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 7/255, green: 12/255, blue: 24/255),
                            Color(red: 14/255, green: 24/255, blue: 42/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
        }
    }
}
