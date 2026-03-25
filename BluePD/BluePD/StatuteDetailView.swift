import SwiftUI

struct StatuteDetailView: View {
    let stateName: String
    let categoryName: String
    let statute: StateStatute

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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(statute.title)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("\(stateName) • \(categoryName)")
                            .font(.headline)
                            .foregroundColor(.blue)

                        Text(statute.statuteNumber)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    detailCard(title: "Statute Description", text: statute.description)
                    detailCard(title: "Officer Notes", text: statute.notes)
                }
                .padding(20)
            }
        }
        .navigationTitle("Statute")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func detailCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(text)
                .foregroundColor(.white.opacity(0.88))
                .lineSpacing(4)
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
