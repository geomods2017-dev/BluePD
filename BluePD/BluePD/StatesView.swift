import SwiftUI

struct StatesView: View {
    let statutes: [StateStatute] = [
        StateStatute(
            state: "Indiana",
            codeTitle: "Indiana Criminal Code",
            summary: "Access Indiana criminal statutes.",
            link: "https://iga.in.gov/laws"
        ),
        StateStatute(
            state: "Illinois",
            codeTitle: "Illinois Compiled Statutes",
            summary: "Access Illinois statutes.",
            link: "https://www.ilga.gov/legislation/ilcs/ilcs.asp"
        )
    ]

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
