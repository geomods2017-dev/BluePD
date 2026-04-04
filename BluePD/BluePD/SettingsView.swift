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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                headerCard

                settingsSectionCard(title: "BluePD Pro", systemImage: "star.fill") {
                    VStack(spacing: 14) {
                        if storeManager.isPro {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.green.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(Color.green.opacity(0.25), lineWidth: 1)
                                        )

                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(.green)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .frame(width: 44, height: 44)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pro Unlocked")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(SettingsPalette.primaryText)

                                    Text("Premium access is active on this account.")
                                        .font(.subheadline)
                                        .foregroundStyle(SettingsPalette.secondaryText)
                                }

                                Spacer()
                            }
                            .padding(16)
                            .bluePDInnerCard(cornerRadius: 20)
                        } else {
                            Button {
                                Task {
                                    purchaseStatusMessage = "Contacting App Store..."
                                    await storeManager.purchase()

                                    if storeManager.isPro {
                                        purchaseStatusMessage = "BluePD Pro unlocked."
                                    } else {
                                        purchaseStatusMessage = "Purchase was not completed."
                                    }
                                }
                            } label: {
                                Text("Upgrade to Pro ($4.99)")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(BluePDPrimaryButtonStyle())
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
                        .buttonStyle(BluePDTextButtonStyle())

                        if !purchaseStatusMessage.isEmpty {
                            Text(purchaseStatusMessage)
                                .font(.caption)
                                .foregroundStyle(SettingsPalette.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                settingsSectionCard(title: "Officer Profile", systemImage: "person.fill") {
                    Button {
                        showProfileEditor = true
                    } label: {
                        HStack(spacing: 14) {
                            iconContainer(systemImage: "person.crop.circle.badge.plus", size: 44, iconSize: 18)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create or Edit Profile")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(SettingsPalette.primaryText)

                                Text("Update officer, badge, rank, unit, and agency details.")
                                    .font(.subheadline)
                                    .foregroundStyle(SettingsPalette.secondaryText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(SettingsPalette.tertiaryText)
                        }
                        .padding(16)
                        .bluePDInnerCard(cornerRadius: 20)
                    }
                    .buttonStyle(.plain)
                }

                settingsSectionCard(title: "Defaults", systemImage: "slider.horizontal.3") {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Default State")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(SettingsPalette.secondaryText)

                            Picker("Default State", selection: $defaultState) {
                                ForEach(states, id: \.self) { state in
                                    Text(state).tag(state)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .frame(height: 58)
                            .bluePDInnerCard(cornerRadius: 18)
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
                    VStack(spacing: 14) {
                        settingsToggleRow(
                            title: "Enable Face ID",
                            subtitle: hasValidPIN ? "Use biometrics to unlock" : "Create a PIN first to enable Face ID",
                            systemImage: "faceid",
                            isOn: $useBiometrics
                        )
                        .onChange(of: useBiometrics) { newValue in
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
                            .buttonStyle(BluePDPrimaryButtonStyle())
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No PIN Created")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(SettingsPalette.primaryText)

                                Text("A passcode has not been created yet. The app will require passcode setup on the next login.")
                                    .font(.subheadline)
                                    .foregroundStyle(SettingsPalette.secondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .bluePDInnerCard(cornerRadius: 20)
                        }

                        if showSecurityMessage {
                            Text(securityMessage)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(
                                    securityMessage == "PIN updated."
                                    ? Color.green
                                    : Color.red.opacity(0.95)
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
                    }
                    .buttonStyle(BluePDDestructiveButtonStyle())
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(backgroundGradient.ignoresSafeArea())
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

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 2/255, green: 7/255, blue: 18/255),
                Color(red: 7/255, green: 17/255, blue: 31/255),
                Color(red: 10/255, green: 24/255, blue: 44/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BluePD Settings")
                .font(.title.weight(.bold))
                .foregroundStyle(SettingsPalette.primaryText)

            Text("Manage security, defaults, appearance, account settings, and profile information.")
                .font(.subheadline)
                .foregroundStyle(SettingsPalette.secondaryText)
        }
        .padding(20)
        .bluePDCard(cornerRadius: 24)
    }

    private func settingsSectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(SettingsPalette.primaryText)
                    .font(.headline.weight(.semibold))

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(SettingsPalette.primaryText)
            }

            content()
        }
        .padding(18)
        .bluePDCard(cornerRadius: 24)
    }

    private func settingsToggleRow(
        title: String,
        subtitle: String,
        systemImage: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            iconContainer(systemImage: systemImage, size: 46, iconSize: 18)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SettingsPalette.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SettingsPalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 20)
    }

    private func iconContainer(systemImage: String, size: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.blue.opacity(0.22), lineWidth: 1)
                )

            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(SettingsPalette.accent)
        }
        .frame(width: size, height: size)
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
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(SettingsPalette.accent)

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(SettingsPalette.secondaryText)
            }

            SecureField(title, text: $text)
                .keyboardType(.numberPad)
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .foregroundStyle(SettingsPalette.primaryText)
        }
    }
}

private enum SettingsPalette {
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.74)
    static let tertiaryText = Color.white.opacity(0.38)
    static let accent = Color(red: 0.10, green: 0.56, blue: 1.00)
}

private struct BluePDCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.070),
                                Color.white.opacity(0.032)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
    }
}

private struct BluePDInnerCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.050),
                                Color.white.opacity(0.028)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.065), lineWidth: 1)
            )
    }
}

private extension View {
    func bluePDCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(BluePDCardModifier(cornerRadius: cornerRadius))
    }

    func bluePDInnerCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(BluePDInnerCardModifier(cornerRadius: cornerRadius))
    }
}

private struct BluePDPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.08, green: 0.56, blue: 0.98),
                                Color(red: 0.05, green: 0.42, blue: 0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .shadow(color: Color.blue.opacity(0.18), radius: 12, x: 0, y: 8)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct BluePDDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.red.opacity(0.90))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct BluePDTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(SettingsPalette.accent.opacity(configuration.isPressed ? 0.75 : 1.0))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }
}
