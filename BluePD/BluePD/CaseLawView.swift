import SwiftUI

struct CaseLawView: View {
    let cases: [CaseLawItem] = [
        CaseLawItem(
            title: "Terry v. Ohio",
            court: "U.S. Supreme Court",
            date: "1968",
            summary: "Established stop and frisk based on reasonable suspicion.",
            citation: "392 U.S. 1"
        )
    ]

    var body: some View {
        List(cases) { item in
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
        .navigationTitle("Case Law")
    }
}
