import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                VStack(alignment: .leading, spacing: 14) {
                    Text("Priority Tools")
                        .font(.headline)
                        .padding(.horizontal)

                    NavigationLink(destination: MirandaView()) {
                        FeaturedHomeCard(
                            title: "Miranda Warnings",
                            subtitle: "English and Spanish read mode",
                            systemImage: "exclamationmark.shield.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: SFSTView()) {
                        HomeCard(
                            title: "SFST",
                            subtitle: "Guided clues, notes, and report builder",
                            systemImage: "checklist"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: PastReportsView()) {
                        HomeCard(
                            title: "Past Reports",
                            subtitle: "Open saved SFST narratives",
                            systemImage: "doc.text"
                        )
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Reference")
                        .font(.headline)
                        .padding(.horizontal)

                    NavigationLink(destination: CaseLawView()) {
                        HomeCard(
                            title: "Case Law",
                            subtitle: "Recent legal reference",
                            systemImage: "book.closed"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: StatesView()) {
                        HomeCard(
                            title: "State Statutes",
                            subtitle: "Open official state code sites",
                            systemImage: "map"
                        )
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Utilities")
                        .font(.headline)
                        .padding(.horizontal)

                    NavigationLink(destination: EvidenceView()) {
                        HomeCard(
                            title: "Evidence",
                            subtitle: "Photo capture and reference",
                            systemImage: "camera"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: SettingsView()) {
                        HomeCard(
                            title: "Settings",
                            subtitle: "Officer profile and app options",
                            systemImage: "gearshape"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Home")
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Blue PD")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Law Enforcement Quick Access")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

struct FeaturedHomeCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 56, height: 56)

                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            Image(systemName: "chevron.right.circle.fill")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .shadow(radius: 6)
        .padding(.horizontal)
    }
}

struct HomeCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
