import SwiftUI

struct LoginView: View {
    @AppStorage("userPIN") private var userPIN: String = "1234"
    @State private var enteredPIN: String = ""
    @State private var isUnlocked = false
    @State private var showError = false

    var body: some View {
        Group {
            if isUnlocked {
                MainTabView()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.25),
                            Color.black.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)

                        Text("BluePD Secure Login")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Enter PIN to continue")
                            .foregroundColor(.white.opacity(0.8))

                        SecureField("PIN", text: $enteredPIN)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .frame(maxWidth: 220)

                        Button(action: unlockApp) {
                            Text("Unlock")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 220)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        if showError {
                            Text("Incorrect PIN")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func unlockApp() {
        if enteredPIN == userPIN {
            isUnlocked = true
            showError = false
            enteredPIN = ""
        } else {
            showError = true
            enteredPIN = ""
        }
    }
}

#Preview {
    LoginView()
}
