import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("savedPIN") private var savedPIN = ""
    @AppStorage("useBiometrics") private var useBiometrics = true
    @AppStorage("hasCreatedPIN") private var hasCreatedPIN = false

    @State private var pin = ""
    @State private var confirmPIN = ""
    @State private var firstPINEntry = ""
    @State private var errorMessage = ""
    @State private var isAuthenticating = false
    @FocusState private var pinFieldFocused: Bool

    private var isCreatingPIN: Bool {
        !hasCreatedPIN || savedPIN.isEmpty
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 8/255, green: 18/255, blue: 36/255),
                    Color(red: 18/255, green: 45/255, blue: 84/255),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 14) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)

                    Text("BluePD")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text(isCreatingPIN ? "Create Your Passcode" : "Secure Access")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.78))
                }

                VStack(spacing: 16) {
                    if isCreatingPIN {
                        createPINSection
                    } else {
                        loginSection
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red.opacity(0.95))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)

                Spacer()

                Text(isCreatingPIN ? "Create a 4-digit passcode to secure BluePD" : "Authorized personnel only")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            pinFieldFocused = true
        }
    }

    private var createPINSection: some View {
        VStack(spacing: 16) {
            SecureField("Create 4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($pinFieldFocused)
                .padding()
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            SecureField("Confirm 4-digit PIN", text: $confirmPIN)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .padding()
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            Button(action: createPIN) {
                HStack {
                    Image(systemName: "lock.badge.plus.fill")
                    Text("Save PIN")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var loginSection: some View {
        VStack(spacing: 16) {
            SecureField("Enter PIN", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($pinFieldFocused)
                .padding()
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            Button(action: loginWithPIN) {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Login with PIN")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if useBiometrics {
                Button(action: authenticateWithBiometrics) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Use Face ID")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.12))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .disabled(isAuthenticating)
            }
        }
    }

    private func createPIN() {
        errorMessage = ""

        let trimmedPIN = pin.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPIN = confirmPIN.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedPIN.count == 4, trimmedPIN.allSatisfy(\.isNumber) else {
            errorMessage = "PIN must be exactly 4 digits."
            pin = ""
            confirmPIN = ""
            return
        }

        guard trimmedPIN == trimmedConfirmPIN else {
            errorMessage = "PINs do not match."
            pin = ""
            confirmPIN = ""
            return
        }

        savedPIN = trimmedPIN
        hasCreatedPIN = true
        isLoggedIn = true
        pin = ""
        confirmPIN = ""
    }

    private func loginWithPIN() {
        errorMessage = ""

        let trimmedPIN = pin.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedPIN.isEmpty else {
            errorMessage = "Enter your PIN."
            return
        }

        if trimmedPIN == savedPIN {
            isLoggedIn = true
            pin = ""
        } else {
            errorMessage = "Incorrect PIN."
            pin = ""
        }
    }

    private func authenticateWithBiometrics() {
        guard hasCreatedPIN, !savedPIN.isEmpty else {
            errorMessage = "Create a PIN before enabling Face ID."
            return
        }

        let context = LAContext()
        var error: NSError?

        errorMessage = ""
        isAuthenticating = true

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            isAuthenticating = false
            errorMessage = "Face ID is not available on this device."
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock BluePD") { success, _ in
            DispatchQueue.main.async {
                isAuthenticating = false

                if success {
                    isLoggedIn = true
                    pin = ""
                } else {
                    errorMessage = "Authentication failed."
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
