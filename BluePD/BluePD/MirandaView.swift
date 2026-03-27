import SwiftUI

struct MirandaView: View {
    let warnings: [MirandaWarning] = [
        MirandaWarning(
            title: "Standard Miranda Warning",
            text: "You have the right to remain silent. Anything you say can and will be used against you in a court of law. You have the right to an attorney. If you cannot afford one, one will be appointed for you."
        )
    ]

    var body: some View {
        List(warnings) { item in
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)

                Text(item.text)
                    .font(.body)
            }
            .padding(.vertical, 6)
        }
        .navigationTitle("Miranda")
    }
}
