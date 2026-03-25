import SwiftUI

struct StateCategoryView: View {
    let state: StateCodeEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.03, green: 0.07, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(state.stateName)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("Statute Categories")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.72))
                    }

                    if state.categories.isEmpty {
                        Text("No statute categories added yet.")
                            .foregroundColor(.white.opacity(0.65))
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(state.categories) { category in
                                NavigationLink(destination: StatuteListView(stateName: state.stateName, category: category)) {
                                    PoliceCategoryRow(title: category.name, count: category.statutes.count)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(state.stateName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PoliceCategoryRow: View {
    let title: String
    let count: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(count) statutes")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()

            Image(systemName: "folder")
                .foregroundColor(.blue)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.blue.opacity(0.28), lineWidth: 1)
                )
        )
    }
}
