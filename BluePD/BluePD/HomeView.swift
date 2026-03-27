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
                    NavigationLink(destination: MirandaView()) {
                        FeaturedHomeCard(
                            title: "Miranda Warnings",
                            subtitle: "Quick access to advisement language",
                            systemImage: "exclamationmark.shield.fill"
                        )
                    }

                    NavigationLink(destination: SFSTView()) {
                        HomeCard(title: "SFST", systemImage: "checklist")
                    }

                    NavigationLink(destination: CaseLawView()) {
                        HomeCard(title: "New Case Law", systemImage: "book.closed")
                    }

                    NavigationLink(destination: StatesView()) {
                        HomeCard(title: "State Statutes", systemImage: "map")
                    }

                    NavigationLink(destination: EvidenceView()) {
                        HomeCard(title: "Evidence", systemImage: "camera")
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Home")
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
                    .frame(width: 54, height: 54)

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
    }
}

struct HomeCard: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 35)

            Text(title)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.blue.opacity(0.12))
        .cornerRadius(14)
    }
}
