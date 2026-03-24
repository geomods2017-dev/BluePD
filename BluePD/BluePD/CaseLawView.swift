import SwiftUI

struct CaseLawView: View {
    private let updates: [CaseLawUpdate] = [
        .init(title: "Search & Seizure", summary: "Placeholder section for recent search and seizure updates."),
        .init(title: "Traffic Stops", summary: "Add jurisdiction-specific traffic stop developments here."),
        .init(title: "Interviews", summary: "Store interview and custodial interrogation cases here.")
    ]

    var body: some View {
        NavigationStack {
            List(updates) { update in
                VStack(alignment: .leading, spacing: 8) {
                    Text(update.title)
                        .font(.headline)
                    Text(update.summary)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("New Case Law")
        }
    }
}

struct CaseLawUpdate: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
}
