import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                topHeader
                quickStatsRow

                VStack(spacing: 14) {
                    NavigationLink(destination: SFSTView()) {
                        HomeCard(
                            title: "SFST",
                            subtitle: "Field sobriety test notes and roadside reference",
                            systemImage: "checkmark.shield.fill"
                        )
                    }

                    NavigationLink(destination: MirandaView()) {
                        HomeCard(
                            title: "Miranda Warnings",
                            subtitle: "Quick read-aloud reference in the field",
                            systemImage: "exclamationmark.shield.fill"
                        )
                    }

                    NavigationLink(destination: StatesView()) {
                        HomeCard(
                            title: "State Statutes",
                            subtitle: "Quick statute lookup by state and category",
                            systemImage: "map.fill"
                        )
                    }

                    NavigationLink(destination: CaseLawView()) {
                        HomeCard(
                            title: "Case Law",
                            subtitle: "Searchable patrol-focused legal reference",
                            systemImage: "book.closed.fill"
                        )
                    }

                    NavigationLink(destination: PastReportsView()) {
                        HomeCard(
                            title: "Saved Summaries",
                            subtitle: "Stored SFST field notes and generated summaries",
                            systemImage: "doc.text.fill"
                        )
                    }

                    NavigationLink(destination: EvidenceView()) {
                        HomeCard(
                            title: "Evidence",
                            subtitle: "Store and review local evidence photos",
                            systemImage: "camera.fill"
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 7/255, green: 12/255, blue: 24/255),
                    Color(red: 13/255, green: 23/255, blue: 40/255),
                    Color(red: 18/255, green: 29/255, blue: 48/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.blue.opacity(0.16))
                        .frame(width: 64, height: 64)

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("BluePD")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Law Enforcement Quick Access")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer()
            }

            Text("Built for fast access to field tools, legal reference, summaries, and evidence support.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
    }

    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            SmallStatusCard(
                title: "Tools",
                value: "6",
                systemImage: "square.grid.2x2.fill"
            )

            SmallStatusCard(
                title: "Field Ready",
                value: "Yes",
                systemImage: "checkmark.circle.fill"
            )

            SmallStatusCard(
                title: "Access",
                value: "Fast",
                systemImage: "bolt.fill"
            )
        }
    }
}

struct HomeCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 54, height: 54)

                Image(systemName: systemImage)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.70))
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.45))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

struct SmallStatusCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
                .font(.headline)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
