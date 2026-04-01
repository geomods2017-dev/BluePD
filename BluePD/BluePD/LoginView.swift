import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @AppStorage("userPIN") private var userPIN: String = ""
    @AppStorage("hasSetPIN") private var hasSetPIN: Bool = false
    @AppStorage("useFaceID") private var useFaceID: Bool = true

    @State private var enteredPIN: String = ""
    @State private var newPIN: String = ""
    @State private var confirmPIN: String = ""

    @State private var isUnlocked = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAuthenticating = false

    var body: some View {
        Group {
            if isUnlocked {
                MainTabView()
            } else if !hasSetPIN {
                createPINView
            } else {
                loginView
            }
        }
    }

    private var createPINView: some View {
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

            VStack(spacing: 20) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 60))
                    .foregroundColor(.white)

                Text("BluePD Secure Setup")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Create a PIN to protect app access")
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                SecureField("Create PIN", text: $newPIN)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(maxWidth: 240)

                SecureField("Confirm PIN", text: $confirmPIN)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(maxWidth: 240)

                Toggle("Enable Face ID", isOn: $useFaceID)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .frame(maxWidth: 240)

                Button(action: savePIN) {
                    Text("Save PIN")
                        .fontWeight(.semibold)
                        .frame(maxWidth: 240)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
    }

    private var loginView: some View {
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

                Text("Authenticate to continue")
                    .foregroundColor(.white.opacity(0.8))

                if useFaceID {
                    Button(action: authenticateWithFaceID) {
                        Label("Unlock with Face ID", systemImage: "faceid")
                            .fontWeight(.semibold)
                            .frame(maxWidth: 240)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .disabled(isAuthenticating)
                }

                Text("or enter PIN")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)

                SecureField("PIN", text: $enteredPIN)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(maxWidth: 240)

                Button(action: unlockWithPIN) {
                    Text("Unlock")
                        .fontWeight(.semibold)
                        .frame(maxWidth: 240)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .onAppear {
                if useFaceID && !isUnlocked {
                    authenticateWithFaceID()
                }
            }
        }
    }

    private func savePIN() {
        showError = false

        if newPIN.isEmpty || confirmPIN.isEmpty {
            errorMessage = "Please enter and confirm your PIN."
            showError = true
            return
        }

        if newPIN != confirmPIN {
            errorMessage = "PIN entries do not match."
            showError = true
            return
        }

        if newPIN.count < 4 {
            errorMessage = "PIN must be at least 4 digits."
            showError = true
            return
        }

        userPIN = newPIN
        hasSetPIN = true
        newPIN = ""
        confirmPIN = ""
        enteredPIN = ""
        showError = false
    }

    private func unlockWithPIN() {
        if enteredPIN == userPIN {
            isUnlocked = true
            showError = false
            errorMessage = ""
            enteredPIN = ""
        } else {
            errorMessage = "Incorrect PIN."
            showError = true
            enteredPIN = ""
        }
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        showError = false
        errorMessage = ""
        isAuthenticating = true

        let reason = "Unlock BluePD"

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evalError in
                DispatchQueue.main.async {
                    isAuthenticating = false

                    if success {
                        isUnlocked = true
                        showError = false
                        errorMessage = ""
                    } else {
                        errorMessage = evalError?.localizedDescription ?? "Face ID authentication failed."
                        showError = true
                    }
                }
            }
        } else {
            isAuthenticating = false
            errorMessage = "Face ID is not available on this device."
            showError = true
        }
    }
}

#Preview {
    LoginView()
}
