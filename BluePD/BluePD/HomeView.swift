import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("Blue PD")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Law Enforcement Quick Access")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(spacing: 16) {

                    NavigationLink(destination: SFSTView()) {
                        HomeCard(
                            title: "SFST",
                            subtitle: "Field sobriety test notes",
                            systemImage: "checkmark.shield"
                        )
                    }

                    NavigationLink(destination: MirandaView()) {
                        HomeCard(
                            title: "Miranda Warnings",
                            subtitle: "Read aloud (EN / ES)",
                            systemImage: "exclamationmark.shield"
                        )
                    }

                    NavigationLink(destination: StatesView()) {
                        HomeCard(
                            title: "State Statutes",
                            subtitle: "Official code links",
                            systemImage: "map"
                        )
                    }

                    NavigationLink(destination: CaseLawView()) {
                        HomeCard(
                            title: "Case Law",
                            subtitle: "Quick legal reference",
                            systemImage: "book.closed"
                        )
                    }

                    NavigationLink(destination: PastReportsView()) {
                        HomeCard(
                            title: "Saved Summaries",
                            subtitle: "SFST field notes",
                            systemImage: "doc.text"
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Home")
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
                    .frame(width: 50, height: 50)

                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

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
        .cornerRadius(14)
    }
}
