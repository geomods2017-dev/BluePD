import SwiftUI

struct CaseLawEntry: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let year: Int
    let jurisdiction: String
    let category: String
    let holding: String
    let takeaway: String
    let keywords: [String]
}

struct CaseLawView: View {
    @State private var searchText = ""

    private let entries: [CaseLawEntry] = [
        CaseLawEntry(
            title: "Litchfield v. State",
            year: 2005,
            jurisdiction: "Indiana",
            category: "Search & Seizure",
            holding: "Indiana uses a totality-of-the-circumstances test under Article 1, Section 11 rather than strict federal standards.",
            takeaway: "A search can pass federal law but still fail in Indiana. Always consider reasonableness.",
            keywords: ["indiana", "search", "seizure", "litchfield"]
        ),
        CaseLawEntry(
            title: "Pirtle v. State",
            year: 1975,
            jurisdiction: "Indiana",
            category: "Consent Search",
            holding: "A person in custody must be advised of the right to consult an attorney before consenting to a search.",
            takeaway: "Custody + consent search = Pirtle warning required.",
            keywords: ["indiana", "pirtle", "consent", "search"]
        ),
        CaseLawEntry(
            title: "Canonge v. State",
            year: 2024,
            jurisdiction: "Indiana",
            category: "Traffic Stops",
            holding: "A completed stop cannot be extended without separate reasonable suspicion.",
            takeaway: "Do not prolong traffic stops unless you can clearly justify it.",
            keywords: ["traffic", "stop", "indiana", "reasonable suspicion"]
        ),
        CaseLawEntry(
            title: "Plue v. State",
            year: 2024,
            jurisdiction: "Indiana",
            category: "Traffic Stops",
            holding: "Stops are valid while actively completing their purpose without unnecessary delay.",
            takeaway: "Work efficiently—do not delay stops.",
            keywords: ["traffic", "duration", "stop", "indiana"]
        ),
        CaseLawEntry(
            title: "Barnes v. Felix",
            year: 2025,
            jurisdiction: "U.S. Supreme Court",
            category: "Use of Force",
            holding: "Force must be judged under totality of circumstances, not just the final moment.",
            takeaway: "Document everything leading up to force.",
            keywords: ["force", "federal", "totality"]
        ),
        CaseLawEntry(
            title: "Chiaverini v. City of Napoleon",
            year: 2024,
            jurisdiction: "U.S. Supreme Court",
            category: "Arrests",
            holding: "Invalid charges can still create liability even if another charge had probable cause.",
            takeaway: "Each charge must stand on its own.",
            keywords: ["arrest", "charges", "probable cause"]
        )
    ]

    private var filteredEntries: [CaseLawEntry] {
        if searchText.isEmpty {
            return entries.sorted { $0.year > $1.year }
        }

        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText) ||
            $0.jurisdiction.localizedCaseInsensitiveContains(searchText) ||
            $0.keywords.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
        }
        .sorted { $0.year > $1.year }
    }

    var body: some View {
        NavigationStack {
            List(filteredEntries) { entry in
                NavigationLink(destination: CaseLawDetailView(entry: entry)) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(entry.title)
                                .font(.headline)

                            Spacer()

                            Text("\(entry.year)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }

                        Text("\(entry.jurisdiction) • \(entry.category)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(entry.takeaway)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Case Law")
            .searchable(text: $searchText, prompt: "Search case law")
        }
    }
}
