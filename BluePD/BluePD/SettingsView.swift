import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    Text("Blue PD Settings")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
