import SwiftUI

struct CaseLawView: View {
    let cases: [CaseLawItem] =
        JSONDataLoader.shared.load("caselaw", as: [CaseLawItem].self) ?? []

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
