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
    @AppStorage("useFaceID") private var useFaceID: Bool = true
    @AppStorage("savedPIN") private var savedPIN: String = "1234"
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    @State private var currentPIN: String = ""
    @State private var newPIN: String = ""
    @State private var confirmNewPIN: String = ""
    @State private var securityMessage: String = ""
    @State private var showSecurityMessage: Bool = false

    @State private var showProfileEditor = false

    private let states = [
        "Indiana","Illinois","Michigan","Ohio","Kentucky","Tennessee",
        "Florida","Texas","California","New York"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                headerCard

                // MARK: PRO UPGRADE
                settingsSectionCard(title: "BluePD Pro", systemImage: "star.fill") {
                    VStack(spacing: 12) {

                        if storeManager.isPro {
                            Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        } else {
                            Button {
                                Task {
                                    await storeManager.purchase()
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
                        }

                        Button("Restore Purchases") {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }

                // MARK: PROFILE (COLLAPSED)
                settingsSectionCard(title: "Officer Profile", systemImage: "person.fill") {
                    Button {
                        showProfileEditor.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create / Edit Profile")
                                .fontWeight(.semibold)
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

                // MARK: DEFAULTS
                settingsSectionCard(title: "Defaults", systemImage: "slider.horizontal.3") {
                    VStack(spacing: 12) {

                        Picker("Default State", selection: $defaultState) {
                            ForEach(states, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)

                        settingsToggleRow(
                            title: "Auto-Fill Officer Info",
                            subtitle: "Insert stored info into reports",
                            systemImage: "doc.text.fill",
                            isOn: $autoFillOfficerInfo
                        )
                    }
                }

                // MARK: SECURITY
                settingsSectionCard(title: "Security", systemImage: "lock.shield.fill") {
                    VStack(spacing: 12) {

                        settingsToggleRow(
                            title: "Enable Face ID",
                            subtitle: "Use biometrics to unlock",
                            systemImage: "faceid",
                            isOn: $useFaceID
                        )

                        SecureSettingsField(title: "Current PIN", text: $currentPIN, systemImage: "key.fill")
                        SecureSettingsField(title: "New PIN", text: $newPIN, systemImage: "lock.fill")
                        SecureSettingsField(title: "Confirm PIN", text: $confirmNewPIN, systemImage: "checkmark.shield.fill")

                        Button("Change PIN") {
                            changePIN()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.blue))
                        .foregroundColor(.white)

                        if showSecurityMessage {
                            Text(securityMessage)
                                .foregroundColor(.white)
                        }
                    }
                }

                // MARK: APPEARANCE
                settingsSectionCard(title: "Appearance", systemImage: "moon.fill") {
                    settingsToggleRow(
                        title: "Dark Mode",
                        subtitle: "Visual preference",
                        systemImage: "moon.fill",
                        isOn: $darkModeEnabled
                    )
                }

                // MARK: LOGOUT
                settingsSectionCard(title: "Account", systemImage: "person.crop.circle") {
                    Button {
                        isLoggedIn = false
                    } label: {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.red))
                            .foregroundColor(.white)
                    }
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

    // MARK: COMPONENTS

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
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06)))
    }

    private func settingsToggleRow(
        title: String,
        subtitle: String,
        systemImage: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack {
            Image(systemName: systemImage).foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(title).foregroundColor(.white)
                Text(subtitle).font(.caption).foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Toggle("", isOn: isOn).labelsHidden()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.05)))
    }

    private var headerCard: some View {
        Text("BluePD Settings")
            .font(.title2.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func changePIN() {
        if currentPIN != savedPIN {
            securityMessage = "Incorrect PIN"
        } else if newPIN != confirmNewPIN {
            securityMessage = "PIN mismatch"
        } else {
            savedPIN = newPIN
            securityMessage = "PIN updated"
        }
        showSecurityMessage = true
    }
}

// MARK: PROFILE EDITOR

struct ProfileEditorView: View {
    @Environment(\.dismiss) var dismiss

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
                Button("Done") { dismiss() }
            }
        }
    }
}

// MARK: SECURE FIELD

struct SecureSettingsField: View {
    let title: String
    @Binding var text: String
    let systemImage: String

    var body: some View {
        SecureField(title, text: $text)
            .keyboardType(.numberPad)
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.05)))
            .foregroundColor(.white)
    }
}
