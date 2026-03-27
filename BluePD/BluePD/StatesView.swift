import SwiftUI

struct StateStatuteItem: Identifiable {
    let id = UUID()
    let state: String
    let codeTitle: String
    let summary: String
    let link: String
}

struct StatesView: View {
    let statutes: [StateStatuteItem] = [
        StateStatuteItem(
            state: "Indiana",
            codeTitle: "Indiana Criminal Code",
            summary: "Access Indiana criminal statutes.",
            link: "https://iga.in.gov/laws"
        ),
        StateStatuteItem(
            state: "Illinois",
            codeTitle: "Illinois Compiled Statutes",
            summary: "Access Illinois statutes.",
            link: "https://www.ilga.gov/legislation/ilcs/ilcs.asp"
        )
    ]

    var body: some View {
        List(statutes) { item in
            if let url = URL(string: item.link) {
                Link(destination: url) {
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
        }
        .navigationTitle("States")
    }
}
