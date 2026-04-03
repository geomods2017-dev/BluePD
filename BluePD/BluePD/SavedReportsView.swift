import SwiftUI

struct SavedReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var savedReports: [SavedSFSTReport]
    @State private var selectedReport: SavedSFSTReport?

    private let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 3/255, green: 8/255, blue: 18/255),
            Color(red: 7/255, green: 16/255, blue: 30/255),
            Color(red: 12/255, green: 24/255, blue: 42/255)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

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
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(savedReports) { report in
                            Button {
                                selectedReport = report
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(report.subjectName.isEmpty ? "Unnamed Subject" : report.subjectName)
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                        .onDelete { offsets in
                            savedReports.remove(atOffsets: offsets)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .navigationTitle("Saved Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(item: $selectedReport) { report in
                SavedReportDetailView(report: report)
            }
        }
    }
}

struct SavedReportDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let report: SavedSFSTReport

    private let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 3/255, green: 8/255, blue: 18/255),
            Color(red: 7/255, green: 16/255, blue: 30/255),
            Color(red: 12/255, green: 24/255, blue: 42/255)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(report.subjectName.isEmpty ? "Unnamed Subject" : report.subjectName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)

                    Divider()
                        .overlay(Color.white.opacity(0.15))

                    Text(report.reportText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .background(
                backgroundGradient
                    .ignoresSafeArea()
            )
            .navigationTitle("Report Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
