import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Legal Disclaimer")
                    .font(.title)
                    .fontWeight(.bold)

                Text("""
Blue PD is intended for informational and reference purposes only. It does not replace official department policy, legal advice, or formal training.

Users are responsible for ensuring that all actions, procedures, and decisions comply with their agency’s policies, local laws, and current legal standards.

While efforts may be made to keep information accurate and up to date, Blue PD makes no guarantees regarding completeness, accuracy, or suitability for any specific purpose.

Use of this application is at your own risk.
""")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Disclaimer")
    }
}
