import SwiftUI

struct StatesView: View {
    private let states = [
        "Indiana", "Illinois", "Kentucky", "Ohio", "Michigan", "Florida", "Texas", "California"
    ]

    var body: some View {
        NavigationStack {
            List(states, id: \.self) { state in
                NavigationLink(state) {
                    StateDetailView(stateName: state)
                }
            }
            .navigationTitle("State Codes")
        }
    }
}

struct StateDetailView: View {
    let stateName: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(stateName)
                    .font(.largeTitle.bold())

                Text("This is a placeholder page for criminal code references and statutes. Replace this with live state statute data or links in a later version.")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(stateName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
