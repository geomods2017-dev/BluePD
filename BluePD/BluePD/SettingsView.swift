import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var draftName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Display name", text: $draftName)
                        .onAppear {
                            draftName = session.username
                        }

                    Button("Save Display Name") {
                        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            session.username = trimmed
                        }
                    }
                }

                Section("Current User") {
                    Text(session.username)
                }

                Section {
                    Button("Log Out", role: .destructive) {
                        session.logout()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
