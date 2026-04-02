import SwiftUI
import LocalAuthentication

struct LockView: View {
    @Binding var isUnlocked: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text("Secure Access")
                .font(.title2)
                .foregroundColor(.white)

            Button("Unlock") {
                authenticate()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            authenticate()
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock BluePD") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    }
                }
            }
        } else {
            // fallback (no Face ID available)
            isUnlocked = true
        }
    }
}
