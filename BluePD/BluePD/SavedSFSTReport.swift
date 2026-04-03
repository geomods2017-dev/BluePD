import SwiftUI
struct SavedReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var savedReports: [SavedSFSTReport]
    @State private var selectedReport: SavedSFSTReport?

    var body: some View {
        NavigationStack {
            Group {
                if savedReports.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 42))
                            .foregroundColor(.blue)

                        Text("No Saved Reports")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Generated SFST reports will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(savedReports) { report in
                            Button {
                                selectedReport = report
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(report.subjectName)
                                        .foregroundColor(.white)
                                        .font(.headline)

                                    Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                        .onDelete { indexSet in
                            savedReports.remove(atOffsets: indexSet)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 3/255, green: 8/255, blue: 18/255),
                        Color(red: 7/255, green: 16/255, blue: 30/255),
                        Color(red: 12/255, green: 24/255, blue: 42/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Saved Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedReport) { report in
                SavedReportDetailView(report: report)
            }
        }
    }
}
