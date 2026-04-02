import SwiftUI

struct SettingsView: View {
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

    private let states = [
        "Indiana", "Illinois", "Michigan", "Ohio", "Kentucky", "Tennessee", "Florida", "Texas", "California", "New York"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard

                // ✅ PROFILE ENTRY (replaces huge form)
                settingsSectionCard(title: "Officer Profile", systemImage: "person.crop.circle.badge.plus") {
                    NavigationLink(destination: OfficerProfileView()) {
                        HStack(spacing: 14) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .foregroundColor(.blue)

                            VStack(alignment: .leading) {
                                Text("Create / Edit Profile")
                                    .foregroundColor(.white)
                                    .font(.headline)

                                Text("Set officer info for reports")
                                    .foregroundColor(.white.opacity(0.65))
                                    .font(.subheadline)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }

                settingsSectionCard(title: "Defaults", systemImage: "slider.horizontal.3") {
                    VStack(spacing: 12) {

                        Picker("Default State", selection: $defaultState) {
                            ForEach(states, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        .padding(14)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(14)

                        settingsToggleRow(
                            title: "Auto-Fill Officer Info",
                            subtitle: "Include officer details in reports.",
                            systemImage: "doc.text.fill",
                            isOn: $autoFillOfficerInfo
                        )
                    }
                }

                settingsSectionCard(title: "Security", systemImage: "lock.shield.fill") {
                    VStack(spacing: 12) {

                        settingsToggleRow(
                            title: "Enable Face ID",
                            subtitle: "Use biometric unlock",
                            systemImage: "faceid",
                            isOn: $useFaceID
                        )

                        SecureSettingsField(title: "Current PIN", text: $currentPIN, systemImage: "key.fill")
                        SecureSettingsField(title: "New PIN", text: $newPIN, systemImage: "lock.fill")
                        SecureSettingsField(title: "Confirm PIN", text: $confirmNewPIN, systemImage: "checkmark.shield.fill")

                        Button(action: changePIN) {
                            Text("Change PIN")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }

                        if showSecurityMessage {
                            Text(securityMessage)
                                .foregroundColor(securityMessage.contains("success") ? .green : .red)
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
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 3/255, green: 8/255, blue: 18/255),
                    Color(red: 7/255, green: 16/255, blue: 30/255),
                    Color(red: 12/255, green: 24/255, blue: 42/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Settings")
    }

    private func settingsSectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .foregroundColor(.white)
                .font(.headline)

            content()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(18)
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
                Text(subtitle).foregroundColor(.gray).font(.subheadline)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    private var headerCard: some View {
        HStack {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.blue)

            Text("BluePD Settings")
                .foregroundColor(.white)
                .font(.headline)

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    private func changePIN() {
        showSecurityMessage = true

        if currentPIN != savedPIN {
            securityMessage = "Incorrect PIN"
            return
        }

        if newPIN != confirmNewPIN {
            securityMessage = "PIN mismatch"
            return
        }

        savedPIN = newPIN
        securityMessage = "PIN updated successfully."
    }
}

// ✅ NEW PROFILE SCREEN
struct OfficerProfileView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("badgeNumber") private var badgeNumber: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("officerRank") private var officerRank: String = ""
    @AppStorage("officerUnit") private var officerUnit: String = ""

    var body: some View {
        Form {
            TextField("Officer Name", text: $officerName)
            TextField("Badge Number", text: $badgeNumber)
            TextField("Agency", text: $agencyName)
            TextField("Rank", text: $officerRank)
            TextField("Unit", text: $officerUnit)
        }
        .navigationTitle("Officer Profile")
    }
}
