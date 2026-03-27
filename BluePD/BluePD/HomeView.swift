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
                        HomeCard(title: "Miranda Warnings", systemImage: "exclamationmark.shield")
                    }

                    // ✅ ADDED SFST HERE
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
