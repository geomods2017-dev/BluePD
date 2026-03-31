import SwiftUI

struct CaseLawView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"

    private let cases: [CaseLawItem] = CaseLawItem.sampleData

    private var allCategories: [String] {
        ["All"] + Array(Set(cases.map(\.category))).sorted()
    }

    private var filteredCases: [CaseLawItem] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return cases.filter { item in
            let matchesCategory = selectedCategory == "All" || item.category == selectedCategory

            let matchesSearch: Bool
            if trimmedSearch.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch =
                    item.title.localizedCaseInsensitiveContains(trimmedSearch) ||
                    item.category.localizedCaseInsensitiveContains(trimmedSearch) ||
                    item.summary.localizedCaseInsensitiveContains(trimmedSearch) ||
                    item.whyItMatters.localizedCaseInsensitiveContains(trimmedSearch) ||
                    item.keywords.contains(where: { $0.localizedCaseInsensitiveContains(trimmedSearch) })
            }

            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            if filteredCases.isEmpty {
                emptyStateView
            } else {
                List {
                    Section {
                        categoryFilterSection

                        ForEach(filteredCases) { item in
                            NavigationLink(destination: CaseLawDetailView(item: item)) {
                                CaseLawRowCard(item: item)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Case Law")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Legal Reference")
                .font(.headline)

            Text("Search quick patrol summaries by topic, stop type, interrogation issue, officer safety issue, or legal keyword.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search case law, topic, or keyword", text: $searchText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            HStack {
                Label("\(filteredCases.count) entries", systemImage: "book.closed.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if selectedCategory != "All" {
                    Text(selectedCategory)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(allCategories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                selectedCategory == category
                                ? Color.blue
                                : Color(.secondarySystemGroupedBackground)
                            )
                            .foregroundColor(
                                selectedCategory == category ? .white : .primary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)

            Text("No case law entries found")
                .font(.headline)

            Text("Try a different keyword or switch categories.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Clear Filters") {
                searchText = ""
                selectedCategory = "All"
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
}

struct CaseLawRowCard: View {
    let item: CaseLawItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.10))
                    .frame(width: 52, height: 52)

                Image(systemName: iconName(for: item.category))
                    .foregroundColor(.blue)
                    .font(.system(size: 20, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    Text(item.category)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }

                Text(item.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                HStack {
                    Text(item.dateText)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if let citation = item.citation, !citation.isEmpty {
                        Text(citation)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func iconName(for category: String) -> String {
        switch category {
        case "Traffic Stop":
            return "car.fill"
        case "Search & Seizure":
            return "magnifyingglass.circle.fill"
        case "Miranda":
            return "exclamationmark.shield.fill"
        case "Officer Safety":
            return "shield.fill"
        case "Arrest":
            return "person.crop.rectangle"
        case "DUI / SFST":
            return "figure.walk.motion"
        case "Use of Force":
            return "shield.lefthalf.filled"
        case "Interview / Interrogation":
            return "person.wave.2.fill"
        default:
            return "book.closed.fill"
        }
    }
}

struct CaseLawDetailView: View {
    let item: CaseLawItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                topCard

                detailBlock(
                    title: "Summary",
                    body: item.summary
                )

                detailBlock(
                    title: "Why It Matters",
                    body: item.whyItMatters
                )

                if !item.keywords.isEmpty {
                    keywordBlock
                }

                detailBlock(
                    title: "Reminder",
                    body: "This is a quick field reference only. Confirm current case law, controlling jurisdiction, agency policy, and statutory authority before relying on it operationally."
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Case Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var topCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.title)
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 8) {
                Text(item.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())

                Text(item.dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let citation = item.citation, !citation.isEmpty {
                Label(citation, systemImage: "building.columns.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var keywordBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Keywords")
                .font(.headline)

            FlexibleTagView(tags: item.keywords)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func detailBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(body)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct FlexibleTagView: View {
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(chunkedTags(), id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.10))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }

                    Spacer()
                }
            }
        }
    }

    private func chunkedTags() -> [[String]] {
        var result: [[String]] = []
        var currentRow: [String] = []

        for tag in tags {
            if currentRow.count == 3 {
                result.append(currentRow)
                currentRow = [tag]
            } else {
                currentRow.append(tag)
            }
        }

        if !currentRow.isEmpty {
            result.append(currentRow)
        }

        return result
    }
}

struct CaseLawItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let category: String
    let dateText: String
    let summary: String
    let whyItMatters: String
    let citation: String?
    let keywords: [String]

    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        dateText: String,
        summary: String,
        whyItMatters: String,
        citation: String? = nil,
        keywords: [String] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.dateText = dateText
        self.summary = summary
        self.whyItMatters = whyItMatters
        self.citation = citation
        self.keywords = keywords
    }
}

extension CaseLawItem {
    static let sampleData: [CaseLawItem] = [
        CaseLawItem(
            title: "Traffic Stop Extension Limits",
            category: "Traffic Stop",
            dateText: "Quick Reference",
            summary: "A traffic stop may not be prolonged beyond the time reasonably required to address the mission of the stop unless independent legal justification develops.",
            whyItMatters: "Helps avoid unlawfully extending roadside detentions when no new reasonable suspicion or other lawful basis is present.",
            citation: "Rodriguez-type issue",
            keywords: ["traffic stop", "extension", "reasonable suspicion", "detention", "duration"]
        ),
        CaseLawItem(
            title: "Vehicle Search Based on Probable Cause",
            category: "Search & Seizure",
            dateText: "Quick Reference",
            summary: "If probable cause exists that a vehicle contains contraband or evidence, a warrantless vehicle search may be justified under the automobile exception.",
            whyItMatters: "Useful when articulating why a vehicle search was lawful without first obtaining a warrant.",
            citation: "Automobile exception",
            keywords: ["vehicle search", "probable cause", "automobile exception", "contraband", "evidence"]
        ),
        CaseLawItem(
            title: "Miranda and Custodial Questioning",
            category: "Miranda",
            dateText: "Quick Reference",
            summary: "Miranda warnings are generally required before custodial interrogation, but general non-custodial on-scene questioning does not automatically trigger Miranda.",
            whyItMatters: "Helps distinguish voluntary field questioning from custodial interrogation that requires warnings.",
            citation: "Miranda issue",
            keywords: ["miranda", "custody", "interrogation", "warnings", "questioning"]
        ),
        CaseLawItem(
            title: "Plain View Doctrine Basics",
            category: "Search & Seizure",
            dateText: "Quick Reference",
            summary: "An item may be seized without a warrant when the officer is lawfully present, lawful access exists, and the incriminating nature is immediately apparent.",
            whyItMatters: "Useful when documenting warrantless seizure of evidence seen in plain view.",
            citation: "Plain view doctrine",
            keywords: ["plain view", "seizure", "lawful presence", "evidence", "warrantless"]
        ),
        CaseLawItem(
            title: "Terry Frisk Standard",
            category: "Officer Safety",
            dateText: "Quick Reference",
            summary: "A limited frisk for weapons is allowed when specific, articulable facts support a reasonable belief that the person is armed and dangerous.",
            whyItMatters: "Supports lawful officer safety frisk decisions during investigatory encounters.",
            citation: "Terry frisk issue",
            keywords: ["terry", "frisk", "armed", "dangerous", "officer safety", "pat down"]
        ),
        CaseLawItem(
            title: "Search Incident to Arrest Limits",
            category: "Arrest",
            dateText: "Quick Reference",
            summary: "A search incident to arrest generally allows a search of the arrestee and areas within immediate control, subject to current case-law limits.",
            whyItMatters: "Important when documenting the lawful scope of a search conducted after arrest.",
            citation: "Search incident to arrest",
            keywords: ["search incident to arrest", "arrestee", "immediate control", "post-arrest"]
        ),
        CaseLawItem(
            title: "HGN / SFST Evidentiary Issues",
            category: "DUI / SFST",
            dateText: "Patrol Reference",
            summary: "Standardized field sobriety test observations are strongest when instructions, clue observations, and administration details are documented clearly and consistently.",
            whyItMatters: "Reinforces the need to document instructions given, clues observed, environmental conditions, and subject limitations.",
            citation: "SFST documentation issue",
            keywords: ["dui", "sfst", "hgn", "walk-and-turn", "one-leg stand", "impairment"]
        ),
        CaseLawItem(
            title: "Voluntariness of Statements",
            category: "Interview / Interrogation",
            dateText: "Quick Reference",
            summary: "Statements should be voluntary and not the product of coercion, threats, or improper promises.",
            whyItMatters: "Helps preserve admissibility of statements and supports clean report articulation.",
            citation: "Voluntariness issue",
            keywords: ["voluntary statement", "coercion", "promises", "threats", "interview"]
        ),
        CaseLawItem(
            title: "Objective Reasonableness in Force Analysis",
            category: "Use of Force",
            dateText: "Quick Reference",
            summary: "Force is commonly evaluated from the perspective of a reasonable officer on the scene under the totality of the circumstances.",
            whyItMatters: "Useful for understanding how use-of-force decisions are reviewed after rapidly evolving encounters.",
            citation: "Objective reasonableness",
            keywords: ["use of force", "reasonable officer", "totality", "objective reasonableness"]
        )
    ]
}
