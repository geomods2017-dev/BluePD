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
        "Indiana", "Illinois", "Michigan", "Ohio", "Kentucky",
        "Tennessee", "Florida", "Texas", "California", "New York"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                headerCard

                // PROFILE
                settingsSectionCard(title: "Officer Profile", systemImage: "person.crop.circle.badge.plus") {
                    NavigationLink(destination: OfficerProfileView()) {
                        row(title: "Create / Edit Profile", icon: "person.crop.circle.badge.plus")
                    }
                }

                // DEFAULTS
                settingsSectionCard(title: "Defaults", systemImage: "slider.horizontal.3") {
                    VStack(spacing: 12) {
                        Picker("Default State", selection: $defaultState) {
                            ForEach(states, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        settingsToggleRow(
                            title: "Auto-Fill Officer Info",
                            subtitle: "Include details in reports",
                            systemImage: "doc.text.fill",
                            isOn: $autoFillOfficerInfo
                        )
                    }
                }

                // 🔥 NEW UPGRADE SECTION
                settingsSectionCard(title: "Upgrade", systemImage: "star.fill") {
                    Button(action: purchaseUpgrade) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Upgrade to Pro")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                }

                // SECURITY
                settingsSectionCard(title: "Security", systemImage: "lock.shield.fill") {
                    VStack(spacing: 12) {

                        settingsToggleRow(
                            title: "Face ID",
                            subtitle: "Enable biometric unlock",
                            systemImage: "faceid",
                            isOn: $useFaceID
                        )

                        SecureSettingsField(title: "Current PIN", text: $currentPIN)
                        SecureSettingsField(title: "New PIN", text: $newPIN)
                        SecureSettingsField(title: "Confirm PIN", text: $confirmNewPIN)

                        Button("Change PIN", action: changePIN)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)

                        if showSecurityMessage {
                            Text(securityMessage)
                                .foregroundColor(securityMessage.contains("success") ? .green : .red)
                        }
                    }
                }

                // ACCOUNT
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

    // MARK: - Upgrade Action
    private func purchaseUpgrade() {
        print("Upgrade tapped")
        // Next step: connect StoreKit
    }

    // MARK: - UI Helpers
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
        .cornerRadius(16)
    }

    private func row(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(.blue)
            Text(title).foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
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
        .cornerRadius(12)
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

// MARK: - Profile Screen
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

// MARK: - Secure Field
struct SecureSettingsField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .keyboardType(.numberPad)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}
