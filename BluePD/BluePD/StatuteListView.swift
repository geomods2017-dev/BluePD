import SwiftUI

struct StatuteListView: View {
    let stateName: String
    let category: StateCodeCategory

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.03, green: 0.07, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(category.name)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text(stateName)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }

                    VStack(spacing: 12) {
                        ForEach(category.statutes) { statute in
                            NavigationLink(destination: StatuteDetailView(stateName: stateName, categoryName: category.name, statute: statute)) {
                                StatuteRow(statute: statute)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatuteRow: View {
    let statute: StateStatute

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(statute.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.blue.opacity(0.85))
            }

            Text(statute.statuteNumber)
                .font(.subheadline)
                .foregroundColor(.blue)

            Text(statute.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.78))
                .lineLimit(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.blue.opacity(0.28), lineWidth: 1)
                )
        )
    }
}
