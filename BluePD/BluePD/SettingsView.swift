import SwiftUI

struct SettingsView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("badgeNumber") private var badgeNumber: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false

    var body: some View {
        Form {
            Section("Officer Profile") {
                TextField("Officer Name", text: $officerName)
                TextField("Badge Number", text: $badgeNumber)
                TextField("Agency Name", text: $agencyName)
            }

            Section("Appearance") {
                Toggle("Dark Mode", isOn: $darkModeEnabled)
            }

            Section("Legal") {
                NavigationLink(destination: DisclaimerView()) {
                    Label("Legal Disclaimer", systemImage: "doc.text")
                }
            }
        }
        .navigationTitle("Settings")
    }
}
