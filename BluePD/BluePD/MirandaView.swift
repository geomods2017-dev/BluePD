import SwiftUI

struct MirandaView: View {
    private let warning = "You have the right to remain silent. Anything you say can and will be used against you in a court of law. You have the right to talk to a lawyer and have the lawyer with you during questioning. If you cannot afford a lawyer, one will be appointed to represent you before any questioning if you wish. You can decide at any time to exercise these rights and not answer any questions or make any statements."

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Miranda Warning")
                        .font(.title.bold())

                    Text(warning)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text("Quick Notes")
                        .font(.headline)

                    Label("Read clearly and document the time given.", systemImage: "checkmark.seal")
                    Label("Document any waiver, invocation, or refusal.", systemImage: "checkmark.seal")
                    Label("Use department policy and current state law.", systemImage: "checkmark.seal")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Miranda")
        }
    }
}
