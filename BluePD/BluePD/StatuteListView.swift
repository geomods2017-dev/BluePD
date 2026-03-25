import SwiftUI

struct StateStatuteListView: View {
    let category: StateCodeCategory

    var body: some View {
        List(category.statutes) { statute in
            NavigationLink(destination: StateStatuteDetailView(statute: statute)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(statute.title)
                        .font(.headline)

                    Text(statute.statuteNumber)
                        .font(.subheadline)
                        .foregroundColor(.blue)

                    Text(statute.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(category.name)
    }
}
