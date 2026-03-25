import SwiftUI

struct CaseLawDetailView: View {
    let entry: CaseLawEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.title)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack {
                    Text(entry.jurisdiction)
                    Spacer()
                    Text("\(entry.year)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Text(entry.category)
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Holding")
                        .font(.headline)

                    Text(entry.holding)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Takeaway")
                        .font(.headline)

                    Text(entry.takeaway)
                        .font(.body)
                }

                if !entry.keywords.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Keywords")
                            .font(.headline)

                        Text(entry.keywords.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Case Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CaseLawDetailView(
            entry: CaseLawEntry(
                title: "Litchfield v. State",
                year: 2005,
                jurisdiction: "Indiana",
                category: "Search & Seizure",
                holding: "Indiana uses a totality-of-the-circumstances test under Article 1, Section 11.",
                takeaway: "Always consider reasonableness under Indiana law.",
                keywords: ["indiana", "search", "seizure"]
            )
        )
    }
}
