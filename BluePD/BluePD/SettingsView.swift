import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var storeManager: StoreManager

    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("badgeNumber") private var badgeNumber: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("officerRank") private var officerRank: String = ""
    @AppStorage("officerUnit") private var officerUnit: String = ""
    @AppStorage("defaultState") private var defaultState: String = "Indiana"
    @AppStorage("autoFillOfficerInfo") private var autoFillOfficerInfo: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("useBiometrics") private var useBiometrics: Bool = true
    @AppStorage("savedPIN") private var savedPIN: String = ""
    @AppStorage("hasCreatedPIN") private var hasCreatedPIN: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    @State private var currentPIN: String = ""
    @State private var newPIN: String = ""
    @State private var confirmNewPIN: String = ""
    @State private var securityMessage: String = ""
    @State private var showSecurityMessage: Bool = false
    @State private var showProfileEditor = false
    @State private var purchaseStatusMessage: String = ""

    private let states = [
        "Indiana", "Illinois", "Michigan", "Ohio", "Kentucky",
        "Tennessee", "Florida", "Texas", "California", "New York"
    ]

    private var hasValidPIN: Bool {
        hasCreatedPIN && !savedPIN.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard

                settingsSectionCard(title: "BluePD Pro", systemImage: "star.fill") {
                    VStack(spacing: 12) {
                        if storeManager.isPro {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Pro Unlocked")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)

                                    Text("Premium access is active on this account.")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.65))
                                }

                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.green.opacity(0.12))
                            )
                        } else {
                            Button {
                                Task {
                                    purchaseStatusMessage = "Contacting App Store..."
                                    await storeManager.purchase()

                                    if storeManager.isPro {
                                        purchaseStatusMessage = "BluePD Pro unlocked."
                                    } else {
                                        purchaseStatusMessage = "Purchase not completed."
                                    }
                                }
                            } label: {
                                Text("Upgrade to Pro ($4.99)")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.blue)
                                    )
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                        }

                        Button("Restore Purchases") {
                            Task {
                                purchaseStatusMessage = "Restoring purchases..."
                                await storeManager.restorePurchases()

                                if storeManager.isPro {
                                    purchaseStatusMessage = "Purchases restored."
                                } else {
                                    purchaseStatusMessage = "No previous Pro purchase found."
                                }
                            }
                        }
                        .foregroundColor(.blue)

                        if !purchaseStatusMessage.isEmpty {
                            Text(purchaseStatusMessage)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.75))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                settingsSectionCard(title: "Officer Profile", systemImage: "person.fill") {
                    Button {
                        showProfileEditor = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)

                            Text("Create / Edit Profile")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                }

                settingsSectionCard(title: "Defaults", systemImage: "slider.horizontal.3") {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Default State")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.65))

                            Picker("Default State", selection: $defaultState) {
                                ForEach(states, id: \.self) { state in
                                    Text(state).tag(state)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }

                        settingsToggleRow(
                            title: "Auto-Fill Officer Info",
                            subtitle: "Insert stored info into reports",
                            systemImage: "doc.text.fill",
                            isOn: $autoFillOfficerInfo
                        )
                    }
                }

                settingsSectionCard(title: "Security", systemImage: "lock.shield.fill") {
                    VStack(spacing: 12) {
                        settingsToggleRow(
                            title: "Enable Face ID",
                            subtitle: hasValidPIN ? "Use biometrics to unlock" : "Create a PIN first to enable Face ID",
                            systemImage: "faceid",
                            isOn: $useBiometrics
                        )
                        .onChange(of: useBiometrics) { _, newValue in
                            if newValue && !hasValidPIN {
                                useBiometrics = false
                                securityMessage = "Create a PIN before enabling Face ID."
                                showSecurityMessage = true
                            }
                        }

                        if hasValidPIN {
                            SecureSettingsField(title: "Current PIN", text: $currentPIN, systemImage: "key.fill")
                            SecureSettingsField(title: "New PIN", text: $newPIN, systemImage: "lock.fill")
                            SecureSettingsField(title: "Confirm PIN", text: $confirmNewPIN, systemImage: "checkmark.shield.fill")

                            Button("Change PIN") {
                                changePIN()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.blue)
                            )
                            .foregroundColor(.white)
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("No PIN Created")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("A passcode has not been created yet. The app will require passcode setup on the next login.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }

                        if showSecurityMessage {
                            Text(securityMessage)
                                .font(.caption)
                                .foregroundColor(
                                    securityMessage == "PIN updated."
                                    ? .green
                                    : .red
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                settingsSectionCard(title: "Appearance", systemImage: "moon.fill") {
                    settingsToggleRow(
                        title: "Dark Mode",
                        subtitle: "Visual preference",
                        systemImage: "moon.fill",
                        isOn: $darkModeEnabled
                    )
                }

                settingsSectionCard(title: "Account", systemImage: "person.crop.circle") {
                    Button {
                        isLoggedIn = false
                    } label: {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.red)
                            )
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 7/255, green: 12/255, blue: 24/255),
                    Color(red: 13/255, green: 23/255, blue: 40/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showProfileEditor) {
            ProfileEditorView(
                officerName: $officerName,
                badgeNumber: $badgeNumber,
                agencyName: $agencyName,
                officerRank: $officerRank,
                officerUnit: $officerUnit
            )
        }
    }

    private func settingsSectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .foregroundColor(.white)
                .font(.headline)

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
        )
    }

    private func settingsToggleRow(
        title: String,
        subtitle: String,
        systemImage: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }

    private var headerCard: some View {
        Text("BluePD Settings")
            .font(.title2.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func changePIN() {
        showSecurityMessage = true

        let trimmedCurrentPIN = currentPIN.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNewPIN = newPIN.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPIN = confirmNewPIN.trimmingCharacters(in: .whitespacesAndNewlines)

        guard hasValidPIN else {
            securityMessage = "No existing PIN found."
            return
        }

        guard trimmedCurrentPIN == savedPIN else {
            securityMessage = "Incorrect current PIN."
            currentPIN = ""
            return
        }

        guard trimmedNewPIN.count == 4, trimmedNewPIN.allSatisfy(\.isNumber) else {
            securityMessage = "New PIN must be exactly 4 digits."
            newPIN = ""
            confirmNewPIN = ""
            return
        }

        guard trimmedNewPIN == trimmedConfirmPIN else {
            securityMessage = "PIN mismatch."
            newPIN = ""
            confirmNewPIN = ""
            return
        }

        guard trimmedNewPIN != savedPIN else {
            securityMessage = "New PIN must be different from current PIN."
            newPIN = ""
            confirmNewPIN = ""
            return
        }

        savedPIN = trimmedNewPIN
        hasCreatedPIN = true
        securityMessage = "PIN updated."
        currentPIN = ""
        newPIN = ""
        confirmNewPIN = ""
    }
}

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var officerName: String
    @Binding var badgeNumber: String
    @Binding var agencyName: String
    @Binding var officerRank: String
    @Binding var officerUnit: String

    var body: some View {
        NavigationStack {
            Form {
                TextField("Officer Name", text: $officerName)
                TextField("Badge Number", text: $badgeNumber)
                TextField("Agency", text: $agencyName)
                TextField("Rank", text: $officerRank)
                TextField("Unit", text: $officerUnit)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SecureSettingsField: View {
    let title: String
    @Binding var text: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }

            SecureField(title, text: $text)
                .keyboardType(.numberPad)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.05))
                )
                .foregroundColor(.white)
        }
    }
}
