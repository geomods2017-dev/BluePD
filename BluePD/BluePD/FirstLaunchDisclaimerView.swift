import SwiftUI

struct FirstLaunchDisclaimerView: View {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer: Bool = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Before You Continue")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("""
Blue PD is intended for informational and reference purposes only. It does not replace official department policy, legal advice, or formal training.

You are responsible for ensuring that all actions, procedures, and decisions comply with your agency’s policies, local laws, and current legal standards.

By continuing, you acknowledge that you understand and accept this disclaimer.
""")
                .font(.body)

                Spacer()

                Button(action: {
                    hasAcceptedDisclaimer = true
                }) {
                    Text("I Acknowledge")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding()
            .navigationTitle("Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
