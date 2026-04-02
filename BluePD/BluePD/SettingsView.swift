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

                settingsSectionCard(
                    title: "Officer Profile",
                    systemImage: "person.text.rectangle.fill"
                ) {
                    VStack(spacing: 12) {
                        SettingsInputField(
                            title: "Officer Name",
                            text: $officerName,
                            systemImage: "person.fill"
                        )

                        SettingsInputField(
                            title: "Badge Number",
                            text: $badgeNumber,
                            systemImage: "number.square.fill"
                        )

                        SettingsInputField(
                            title: "Agency Name",
                            text: $agencyName,
                            systemImage: "building.2.fill"
                        )

                        SettingsInputField(
                            title: "Rank / Title",
                            text: $officerRank,
                            systemImage: "chevron.up.square.fill"
                        )

                        SettingsInputField(
                            title: "Unit",
                            text: $officerUnit,
                            systemImage: "shield.fill"
                        )
                    }
                }

                settingsSectionCard(
                    title: "Defaults",
                    systemImage: "slider.horizontal.3"
                ) {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text("Default State")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.78))
                            } icon: {
                                Image(systemName: "map.fill")
                                    .foregroundColor(.blue)
                            }

                            Picker("Default State", selection: $defaultState) {
                                ForEach(states, id: \.self) { state in
                                    Text(state).tag(state)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }

                        settingsToggleRow(
                            title: "Auto-Fill Officer Info",
                            subtitle: "Include stored officer details in generated summaries.",
                            systemImage: "doc.text.fill",
                            isOn: $autoFillOfficerInfo
                        )
                    }
                }

                settingsSectionCard(
                    title: "Security",
                    systemImage: "lock.shield.fill"
                ) {
                    VStack(spacing: 12) {
                        settingsToggleRow(
                            title: "Enable Face ID",
                            subtitle: "Allow biometric unlock when available.",
                            systemImage: "faceid",
                            isOn: $useFaceID
                        )

                        SecureSettingsField(
                            title: "Current PIN",
                            text: $currentPIN,
                            systemImage: "key.fill"
                        )

                        SecureSettingsField(
                            title: "New PIN",
                            text: $newPIN,
                            systemImage: "lock.fill"
                        )

                        SecureSettingsField(
                            title: "Confirm New PIN",
                            text: $confirmNewPIN,
                            systemImage: "checkmark.shield.fill"
                        )

                        Button(action: changePIN) {
                            Text("Change PIN")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.blue)
                                )
                                .foregroundColor(.white)
                        }

                        if showSecurityMessage {
                            Text(securityMessage)
                                .font(.subheadline)
                                .foregroundColor(
                                    securityMessage == "PIN updated successfully."
                                    ? .green
                                    : .red
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                settingsSectionCard(
                    title: "Appearance",
                    systemImage: "circle.lefthalf.filled"
                ) {
                    settingsToggleRow(
                        title: "Dark Mode",
                        subtitle: "Stores a visual preference for future use.",
                        systemImage: darkModeEnabled ? "moon.fill" : "sun.max.fill",
                        isOn: $darkModeEnabled
                    )
                }

                settingsSectionCard(
                    title: "Legal",
                    systemImage: "doc.text.fill"
                ) {
                    NavigationLink(destination: DisclaimerView()) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.blue.opacity(0.14))
                                    .frame(width: 46, height: 46)

                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Legal Disclaimer")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("Read important legal and operational guidance.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.68))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                }

                settingsSectionCard(
                    title: "Account",
                    systemImage: "person.crop.circle.badge.checkmark"
                ) {
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.red.opacity(0.9))
                        )
                        .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 7/255, green: 12/255, blue: 24/255),
                    Color(red: 13/255, green: 23/255, blue: 40/255),
                    Color(red: 18/255, green: 29/255, blue: 48/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func settingsSectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue.opacity(0.16))
                        .frame(width: 58, height: 58)

                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("BluePD Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Manage officer information, security, and default app preferences.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer()
            }

            Text("Stored officer details can be inserted into summaries and future report workflows.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
    }

    private func settingsToggleRow(
        title: String,
        subtitle: String,
        systemImage: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func changePIN() {
        showSecurityMessage = true
        securityMessage = ""

        if currentPIN != savedPIN {
            securityMessage = "Current PIN is incorrect."
            return
        }

        if newPIN.isEmpty || confirmNewPIN.isEmpty {
            securityMessage = "Please complete all PIN fields."
            return
        }

        if newPIN != confirmNewPIN {
            securityMessage = "New PIN entries do not match."
            return
        }

        if newPIN.count < 4 {
            securityMessage = "New PIN must be at least 4 digits."
            return
        }

        savedPIN = newPIN
        securityMessage = "PIN updated successfully."
        currentPIN = ""
        newPIN = ""
        confirmNewPIN = ""
    }
}

struct SettingsInputField: View {
    let title: String
    @Binding var text: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.78))
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

            TextField(title, text: $text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        }
    }
}

struct SecureSettingsField: View {
    let title: String
    @Binding var text: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.78))
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

            SecureField(title, text: $text)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .onChange(of: text) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count > 6 {
                        text = String(filtered.prefix(6))
                    } else {
                        text = filtered
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
