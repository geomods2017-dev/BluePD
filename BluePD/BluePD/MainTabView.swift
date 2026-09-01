import SwiftUI

struct MainTabView: View {
    @AppStorage(BluePDTheme.daylightModeKey) private var daylightModeEnabled: Bool = false

    init() {
        Self.applyTabBarAppearance()
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "shield.fill")
            }

            ReferenceView()
                .tabItem {
                    Label("Reference", systemImage: "book.closed.fill")
                }

            NavigationStack {
                EvidenceView()
            }
            .tabItem {
                Label("Evidence", systemImage: "camera.fill")
            }

            QuickCardsView()
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
        .background(BluePDTheme.backgroundTop.ignoresSafeArea())
        .onChange(of: daylightModeEnabled) { _ in
            Self.applyTabBarAppearance()
        }
    }

    private static func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = UIColor(BluePDTheme.backgroundTop)
        appearance.shadowColor = UIColor(BluePDTheme.innerCardStroke)

        let selectedColor = UIColor(BluePDTheme.accent)
        let normalColor = UIColor(BluePDTheme.tertiaryText)

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
}

#Preview {
    MainTabView()
        .environmentObject(StoreManager())
        .environmentObject(CloudSyncManager())
}
