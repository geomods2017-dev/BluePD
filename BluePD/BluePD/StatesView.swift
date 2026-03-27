import SwiftUI
import UIKit

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
            codeTitle: "Indiana Code",
            summary: "Open the official Indiana Code website.",
            link: "https://iga.in.gov/laws/2025/ic/titles/1"
        ),
        StateStatuteItem(
            state: "Illinois",
            codeTitle: "Illinois Compiled Statutes",
            summary: "Open the official Illinois statutes website.",
            link: "https://www.ilga.gov/legislation/ilcs/ilcs.asp"
        )
    ]

    var body: some View {
        List(statutes) { item in
            Button(action: {
                openLink(item.link)
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.state)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(item.codeTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(item.summary)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("States")
    }

    private func openLink(_ link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}
