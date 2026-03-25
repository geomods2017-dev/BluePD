import SwiftUI

struct CaseLawDetailView: View {
    let entry: CaseLawEntry

    var body: some View {
        List {
            Section("Case") {
                Text(entry.title)
                Text("\(entry.jurisdiction) • \(entry.year)")
            }

            Section("Holding") {
                Text(entry.holding)
            }

            Section("Officer Takeaway") {
                Text(entry.takeaway)
            }
        }
        .navigationTitle("Details")
    }
}
