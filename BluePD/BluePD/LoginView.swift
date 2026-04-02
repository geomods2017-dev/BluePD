import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("savedPIN") private var savedPIN = "1234"
    @AppStorage("useBiometrics") private var useBiometrics = true

    @State private var pin = ""
    @State private var errorMessage = ""
    @State private var isAuthenticating = false
    @FocusState private var pinFieldFocused: Bool

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

                    Text("Secure Access")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.78))
                }

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

                Text("Authorized personnel only")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            pinFieldFocused = true
        }
    }

    private func loginWithPIN() {
        errorMessage = ""

        guard !pin.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter your PIN."
            return
        }

        if pin == savedPIN {
            isLoggedIn = true
            pin = ""
        } else {
            errorMessage = "Incorrect PIN."
            pin = ""
        }
    }

    private func authenticateWithBiometrics() {
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
