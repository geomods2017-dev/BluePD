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
    @State private var showSecurityMessage = false
    @State private var showProfileEditor = false
    @State private var purchaseStatusMessage: String = ""
    @State private var isPurchasingPro = false
    @State private var isRestoringPurchases = false

    private let states = [
        "Indiana", "Illinois", "Michigan", "Ohio", "Kentucky",
        "Tennessee", "Florida", "Texas", "California", "New York"
    ]

    private var hasValidPIN: Bool {
        hasCreatedPIN && !savedPIN.isEmpty
    }

    private var canAttemptPurchase: Bool {
        !isPurchasingPro && !isRestoringPurchases && !storeManager.isLoadingProducts
    }

    private var proPriceText: String {
        storeManager.product?.displayPrice ?? "$4.99"
    }

    private var purchaseButtonTitle: String {
        if isPurchasingPro {
            return "Processing..."
        }

        if storeManager.isLoadingProducts {
            return "Loading..."
        }

        return "Upgrade to Pro (\(proPriceText))"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                headerCard

                settingsSectionCard(title: "BluePD Pro", systemImage: "star.fill") {
                    VStack(spacing: 14) {
                        if storeManager.isPro {
                            proUnlockedCard
                        } else {
                            proPurchaseCard
                        }

                        Button(isRestoringPurchases ? "Restoring..." : "Restore Purchases") {
                            restorePurchases()
                        }
                        .buttonStyle(BluePDTextButtonStyle())
                        .disabled(isPurchasingPro || isRestoringPurchases)

                        if !purchaseStatusMessage.isEmpty {
                            Text(purchaseStatusMessage)
                                .font(.caption)
                                .foregroundStyle(BluePDTheme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                settingsSectionCard(title: "Officer Profile", systemImage: "person.fill") {
                    Button {
                        showProfileEditor = true
                    } label: {
                        HStack(spacing: 14) {
                            BluePDIconContainer(
                                systemImage: "person.crop.circle.badge.plus",
                                size: 44,
                                iconSize: 18
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create or Edit Profile")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(BluePDTheme.primaryText)

                                Text("Update officer, badge, rank, unit, and agency details.")
                                    .font(.subheadline)
                                    .foregroundStyle(BluePDTheme.secondaryText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(BluePDTheme.tertiaryText)
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
                                .foregroundStyle(BluePDTheme.secondaryText)

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
                                    .foregroundStyle(BluePDTheme.primaryText)

                                Text("A passcode has not been created yet. The app will require passcode setup on the next login.")
                                    .font(.subheadline)
                                    .foregroundStyle(BluePDTheme.secondaryText)
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
                                    ? BluePDTheme.success
                                    : BluePDTheme.danger.opacity(0.95)
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
        .background(BluePDTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await storeManager.loadProducts()
            await storeManager.refreshPurchasedStatus()

            if purchaseStatusMessage.isEmpty,
               let error = storeManager.errorMessage,
               !error.isEmpty {
                purchaseStatusMessage = error
            }
        }
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

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BluePD Settings")
                .font(.title.weight(.bold))
                .foregroundStyle(BluePDTheme.primaryText)

            Text("Manage security, defaults, appearance, account settings, and profile information.")
                .font(.subheadline)
                .foregroundStyle(BluePDTheme.secondaryText)
        }
        .padding(20)
        .bluePDCard(cornerRadius: 24)
    }

    private var proUnlockedCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(BluePDTheme.success.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(BluePDTheme.success.opacity(0.25), lineWidth: 1)
                    )

                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(BluePDTheme.success)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text("Pro Unlocked")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text("Premium access is active on this account.")
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
            }

            Spacer()
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 20)
    }

    private var proPurchaseCard: some View {
        VStack(spacing: 12) {
            Button {
                purchasePro()
            } label: {
                Text(purchaseButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BluePDPrimaryButtonStyle())
            .disabled(!canAttemptPurchase)

            if storeManager.isLoadingProducts {
                Text("Loading Pro upgrade...")
                    .font(.caption)
                    .foregroundStyle(BluePDTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if storeManager.product == nil {
                Text("Pro upgrade could not be loaded. Tap Upgrade to retry.")
                    .font(.caption)
                    .foregroundStyle(BluePDTheme.warning.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("Retry Loading Pro") {
                    Task {
                        purchaseStatusMessage = "Retrying App Store..."
                        await storeManager.loadProducts()

                        if storeManager.product == nil {
                            purchaseStatusMessage = storeManager.errorMessage ?? "Pro upgrade is unavailable."
                        } else {
                            purchaseStatusMessage = "Pro upgrade loaded."
                        }
                    }
                }
                .buttonStyle(BluePDTextButtonStyle())
            }
        }
    }

    private func settingsSectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(BluePDTheme.primaryText)
                    .font(.headline.weight(.semibold))

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)
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
            BluePDIconContainer(
                systemImage: systemImage,
                size: 46,
                iconSize: 18
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 20)
    }

    private func purchasePro() {
        guard !isPurchasingPro else { return }

        isPurchasingPro = true
        purchaseStatusMessage = "Contacting App Store..."

        Task {
            await storeManager.purchase()

            isPurchasingPro = false

            if storeManager.isPro {
                purchaseStatusMessage = "BluePD Pro unlocked."
            } else if let error = storeManager.errorMessage, !error.isEmpty {
                purchaseStatusMessage = error
            } else if storeManager.product == nil {
                purchaseStatusMessage = "Pro upgrade is unavailable. Verify Product ID and App Store Connect setup."
            } else {
                purchaseStatusMessage = "Purchase was not completed."
            }
        }
    }

    private func restorePurchases() {
        guard !isRestoringPurchases else { return }

        isRestoringPurchases = true
        purchaseStatusMessage = "Restoring purchases..."

        Task {
            await storeManager.restorePurchases()

            isRestoringPurchases = false

            if storeManager.isPro {
                purchaseStatusMessage = "Purchases restored."
            } else if let error = storeManager.errorMessage, !error.isEmpty {
                purchaseStatusMessage = error
            } else {
                purchaseStatusMessage = "No previous Pro purchase found."
            }
        }
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
                    .foregroundStyle(BluePDTheme.accent)

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(BluePDTheme.secondaryText)
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
                .foregroundStyle(BluePDTheme.primaryText)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(StoreManager())
    }
}
