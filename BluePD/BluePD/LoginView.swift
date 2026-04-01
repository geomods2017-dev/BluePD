import SwiftUI
import LocalAuthentication
import Security

struct LoginView: View {
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("hasSetPIN") private var hasSetPIN: Bool = false
    @AppStorage("useFaceID") private var useFaceID: Bool = true
    @AppStorage("lastActiveTime") private var lastActiveTime: Double = 0

    @State private var enteredPIN: String = ""
    @State private var newPIN: String = ""
    @State private var confirmPIN: String = ""

    @State private var isUnlocked = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAuthenticating = false
    @State private var hasAttemptedBiometricOnAppear = false

    private let autoLockTimeout: Double = 60

    var body: some View {
        Group {
            if isUnlocked {
                MainTabView()
            } else {
                ZStack {
                    backgroundView
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                        }

                    VStack(spacing: 24) {
                        Spacer(minLength: 20)

                        brandHeader

                        if !hasSetPIN {
                            setupCard
                        } else {
                            loginCard
                        }

                        if showError {
                            errorCard(message: errorMessage)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onAppear {
            evaluateAutoLockOnLaunch()
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 7/255, green: 12/255, blue: 24/255),
                Color(red: 13/255, green: 23/255, blue: 40/255),
                Color(red: 18/255, green: 29/255, blue: 48/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.blue.opacity(0.16))
                    .frame(width: 82, height: 82)

                Image(systemName: !hasSetPIN ? "shield.lefthalf.filled" : "lock.shield.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 6) {
                Text(!hasSetPIN ? "BluePD Secure Setup" : "BluePD Secure Login")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(!hasSetPIN
                     ? "Create a secure PIN and choose whether to enable Face ID."
                     : "Authenticate to access reports, evidence, and field tools.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeader(
                title: "Create Access PIN",
                subtitle: "This PIN will be required when biometric unlock is unavailable."
            )

            PINField(
                title: "Create PIN",
                text: $newPIN,
                placeholder: "Enter PIN"
            )

            PINField(
                title: "Confirm PIN",
                text: $confirmPIN,
                placeholder: "Re-enter PIN"
            )

            biometricToggleCard

            Button(action: savePIN) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                    Text("Save Security Settings")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue)
                )
                .foregroundColor(.white)
            }
            .padding(.top, 4)
        }
        .padding(22)
        .background(cardBackground)
    }

    private var loginCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeader(
                title: "Unlock BluePD",
                subtitle: "Use Face ID or enter your PIN below."
            )

            if useFaceID {
                Button(action: authenticateWithBiometrics) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Unlock with Face ID")
                                .fontWeight(.semibold)

                            Text("Fast secure access")
                                .font(.caption)
                                .foregroundColor(Color.black.opacity(0.65))
                        }

                        Spacer()

                        if isAuthenticating {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                    )
                    .foregroundColor(.black)
                }
                .buttonStyle(.plain)
                .disabled(isAuthenticating)
            }

            VStack(spacing: 12) {
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.14))
                        .frame(height: 1)

                    Text("OR ENTER PIN")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.58))
                        .padding(.horizontal, 6)

                    Rectangle()
                        .fill(Color.white.opacity(0.14))
                        .frame(height: 1)
                }

                PINField(
                    title: "PIN Code",
                    text: $enteredPIN,
                    placeholder: "Enter PIN"
                )

                Button(action: unlockWithPIN) {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.open.fill")
                        Text("Unlock")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.blue)
                    )
                    .foregroundColor(.white)
                }
            }
        }
        .padding(22)
        .background(cardBackground)
        .onAppear {
            if useFaceID && !hasAttemptedBiometricOnAppear {
                hasAttemptedBiometricOnAppear = true
                authenticateWithBiometrics()
            }
        }
    }

    private var biometricToggleCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: "faceid")
                    .foregroundColor(.blue)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Enable Face ID")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Use biometric authentication when available.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer()

            Toggle("", isOn: $useFaceID)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorCard(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.red.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.red.opacity(0.24), lineWidth: 1)
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func savePIN() {
        hideKeyboard()
        showError = false
        errorMessage = ""

        if newPIN.isEmpty || confirmPIN.isEmpty {
            errorMessage = "Please enter and confirm your PIN."
            showError = true
            triggerErrorHaptic()
            return
        }

        if newPIN != confirmPIN {
            errorMessage = "PIN entries do not match."
            showError = true
            triggerErrorHaptic()
            return
        }

        if newPIN.count < 4 {
            errorMessage = "PIN must be at least 4 digits."
            showError = true
            triggerErrorHaptic()
            return
        }

        let didSave = KeychainManager.savePIN(newPIN)

        guard didSave else {
            errorMessage = "Unable to save your PIN."
            showError = true
            triggerErrorHaptic()
            return
        }

        hasSetPIN = true
        enteredPIN = ""
        newPIN = ""
        confirmPIN = ""
        showError = false
        errorMessage = ""
        hasAttemptedBiometricOnAppear = false
        triggerSuccessHaptic()
    }

    private func unlockWithPIN() {
        hideKeyboard()
        showError = false
        errorMessage = ""

        guard let savedPIN = KeychainManager.getPIN() else {
            errorMessage = "No saved PIN was found."
            showError = true
            triggerErrorHaptic()
            return
        }

        if enteredPIN == savedPIN {
            isUnlocked = true
            enteredPIN = ""
            triggerSuccessHaptic()
        } else {
            errorMessage = "Incorrect PIN."
            showError = true
            enteredPIN = ""
            triggerErrorHaptic()
        }
    }

    private func authenticateWithBiometrics() {
        hideKeyboard()

        let context = LAContext()
        var error: NSError?

        showError = false
        errorMessage = ""
        isAuthenticating = true

        let reason = "Unlock BluePD"

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evalError in
                DispatchQueue.main.async {
                    isAuthenticating = false

                    if success {
                        isUnlocked = true
                        showError = false
                        errorMessage = ""
                        triggerSuccessHaptic()
                    } else {
                        let nsError = evalError as NSError?

                        if nsError?.code == LAError.userCancel.rawValue ||
                            nsError?.code == LAError.systemCancel.rawValue ||
                            nsError?.code == LAError.appCancel.rawValue {
                            return
                        }

                        errorMessage = evalError?.localizedDescription ?? "Authentication failed."
                        showError = true
                        triggerErrorHaptic()
                    }
                }
            }
        } else {
            isAuthenticating = false
            errorMessage = error?.localizedDescription ?? "Biometric authentication is not available."
            showError = true
            triggerErrorHaptic()
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .inactive, .background:
            lastActiveTime = Date().timeIntervalSince1970

        case .active:
            let now = Date().timeIntervalSince1970
            if hasSetPIN && (now - lastActiveTime) > autoLockTimeout {
                isUnlocked = false
                hasAttemptedBiometricOnAppear = false
            }

        @unknown default:
            break
        }
    }

    private func evaluateAutoLockOnLaunch() {
        let now = Date().timeIntervalSince1970
        if hasSetPIN && (now - lastActiveTime) > autoLockTimeout {
            isUnlocked = false
        }
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func triggerErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

struct PINField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var maxLength: Int = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.78))

            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            hideKeyboard()
                        }
                    }
                }
                .onChange(of: text) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count > maxLength {
                        text = String(filtered.prefix(maxLength))
                    } else {
                        text = filtered
                    }
                }
        }
    }
}

enum KeychainManager {
    private static let service = "com.bluepd.app"
    private static let account = "bluepd_user_pin"

    static func savePIN(_ pin: String) -> Bool {
        let data = Data(pin.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return true
        }

        var addQuery = query
        addQuery[kSecValueData as String] = data

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        return addStatus == errSecSuccess
    }

    static func getPIN() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let pin = String(data: data, encoding: .utf8) else {
            return nil
        }

        return pin
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
#endif

#Preview {
    LoginView()
}
