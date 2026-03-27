import SwiftUI

struct CaseLawEntry: Identifiable {
    let id = UUID()
    let title: String
    let court: String
    let date: String
    let summary: String
    let citation: String
}

struct CaseLawView: View {
    let cases: [CaseLawEntry] = [
        CaseLawEntry(
            title: "Terry v. Ohio",
            court: "U.S. Supreme Court",
            date: "1968",
            summary: "Established stop and frisk based on reasonable suspicion.",
            citation: "392 U.S. 1"
        ),
        CaseLawEntry(
            title: "Miranda v. Arizona",
            court: "U.S. Supreme Court",
            date: "1966",
            summary: "Established the requirement to advise suspects of key constitutional rights during custodial interrogation.",
            citation: "384 U.S. 436"
        )
    ]

    var body: some View {
        List {
            ForEach(cases) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.headline)

                    Text("\(item.court) • \(item.date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(item.citation)
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text(item.summary)
                        .font(.body)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Case Law")
    }
}
