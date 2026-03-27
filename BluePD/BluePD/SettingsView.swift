import SwiftUI

struct SettingsView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Officer Name", text: $officerName)
            }

            Section("Appearance") {
                Toggle("Dark Mode", isOn: $darkModeEnabled)
            }
        }
        .navigationTitle("Settings")
    }
}
