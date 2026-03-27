import SwiftUI

struct MirandaView: View {
    let warnings: [MirandaWarning] =
        JSONDataLoader.shared.load("miranda", as: [MirandaWarning].self) ?? []

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
