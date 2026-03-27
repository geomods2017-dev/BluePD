import SwiftUI

struct StatesView: View {
    let statutes: [StateStatute] =
        JSONDataLoader.shared.load("states", as: [StateStatute].self) ?? []

    var body: some View {
        List(statutes) { item in
            Link(destination: URL(string: item.link)!) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.state)
                        .font(.headline)

                    Text(item.codeTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(item.summary)
                        .font(.body)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("States")
    }
}
