import SwiftUI

struct FirstLaunchDisclaimerView: View {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        Text("Before You Continue")
                            .font(.largeTitle.bold())

                        Text("""
Blue PD is intended for informational and reference purposes only. It does not replace official department policy, legal advice, or formal training.

You are responsible for ensuring that all actions, procedures, and decisions comply with your agency’s policies, local laws, and current legal standards.

By continuing, you acknowledge that you understand and accept this disclaimer.
""")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                VStack {
                    Button(action: {
                        hasAcceptedDisclaimer = true
                    }) {
                        Text("I Acknowledge")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
