import SwiftUI

struct StateCategoryView: View {
    let state: StateCodeEntry

    var body: some View {
        List {
            ForEach(state.categories) { category in
                NavigationLink(destination: StateStatuteListView(category: category)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(category.name)
                            .font(.headline)

                        Text("\(category.statutes.count) statutes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            if state.categories.isEmpty {
                Text("No statutes added yet.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(state.stateName)
    }
}
