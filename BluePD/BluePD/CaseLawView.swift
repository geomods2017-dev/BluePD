import SwiftUI

struct CaseLawView: View {
    @State private var searchText = ""

    private let cases: [CaseLawItem] = [
        CaseLawItem(
            title: "Traffic Stop Extension Limits",
            category: "Traffic Stop",
            dateText: "Recent Reference",
            summary: "A stop may not be prolonged beyond the time reasonably required to handle the mission of the stop unless independent reasonable suspicion develops.",
            whyItMatters: "Helps officers avoid extending roadside detentions without lawful justification."
        ),
        CaseLawItem(
            title: "Vehicle Search Based on Probable Cause",
            category: "Search & Seizure",
            dateText: "Recent Reference",
            summary: "If probable cause exists that evidence or contraband is inside a vehicle, the vehicle may generally be searched under the automobile exception.",
            whyItMatters: "Useful when articulating why a warrantless vehicle search was lawful."
        ),
        CaseLawItem(
            title: "Miranda and Custodial Questioning",
            category: "Miranda",
            dateText: "Recent Reference",
            summary: "Miranda warnings are required before custodial interrogation. Voluntary, non-custodial questioning does not automatically trigger Miranda.",
            whyItMatters: "Helps distinguish general on-scene questioning from custodial interrogation."
        ),
        CaseLawItem(
            title: "Plain View Doctrine Basics",
            category: "Search & Seizure",
            dateText: "Quick Reference",
            summary: "An item may be seized without a warrant when the officer is lawfully present, the item's incriminating nature is immediately apparent, and lawful access exists.",
            whyItMatters: "Useful when documenting warrantless seizures of visible evidence."
        ),
        CaseLawItem(
            title: "Terry Frisk Standard",
            category: "Officer Safety",
            dateText: "Quick Reference",
            summary: "A limited frisk is permitted when specific, articulable facts support a reasonable belief that the person is armed and dangerous.",
            whyItMatters: "Supports officer safety decisions during lawful stops."
        ),
        CaseLawItem(
            title: "Search Incident to Arrest Limits",
            category: "Arrest",
            dateText: "Quick Reference",
            summary: "A search incident to arrest generally permits a search of the arrestee and areas within immediate control, subject to current case law limits.",
            whyItMatters: "Important when articulating the lawful scope of a post-arrest search."
        )
    ]

    private var filteredCases: [CaseLawItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return cases
        }

        return cases.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.category.localizedCaseInsensitiveContains(trimmed) ||
            $0.summary.localizedCaseInsensitiveContains(trimmed) ||
            $0.whyItMatters.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            List {
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && filteredCases.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text("No case law entries found")
                            .font(.headline)

                        Text("Try searching by topic, title, or category.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .listRowBackground(Color.clear)
                } else {
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
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Case Law")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Legal Reference")
                .font(.headline)

            Text("Quick summaries organized for patrol use. Search by topic, stop type, or legal issue.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search case law", text: $searchText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
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
                    .frame(width: 50, height: 50)

                Image(systemName: iconName(for: item.category))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)

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
                    .lineLimit(2)

                Text(item.dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
            return "handcuffs.fill"
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
                VStack(alignment: .leading, spacing: 8) {
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
                }

                detailBlock(
                    title: "Summary",
                    body: item.summary
                )

                detailBlock(
                    title: "Why It Matters",
                    body: item.whyItMatters
                )

                detailBlock(
                    title: "Reminder",
                    body: "Use this section as a quick reference only. Confirm current case law, statutes, and department policy before relying on it operationally."
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Case Detail")
        .navigationBarTitleDisplayMode(.inline)
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

struct CaseLawItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let dateText: String
    let summary: String
    let whyItMatters: String
}
