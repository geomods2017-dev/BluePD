import SwiftUI

struct MirandaItem: Identifiable {
    let id = UUID()
    let title: String
    let text: String
}

struct MirandaView: View {
    let warnings: [MirandaItem] = [
        MirandaItem(
            title: "Standard Miranda Warning",
            text: "You have the right to remain silent. Anything you say can and will be used against you in a court of law. You have the right to an attorney. If you cannot afford one, one will be appointed for you."
        )
    ]

    var body: some View {
        List {
            ForEach(warnings) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.headline)

                    Text(item.text)
                        .font(.body)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Miranda")
    }
}
