import SwiftUI

struct StateStatuteDetailView: View {
    let statute: StateStatute

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(statute.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(statute.statuteNumber)
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)

                    Text(statute.description)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Officer Notes")
                        .font(.headline)

                    Text(statute.notes)
                }
            }
            .padding()
        }
        .navigationTitle("Statute")
        .navigationBarTitleDisplayMode(.inline)
    }
}
