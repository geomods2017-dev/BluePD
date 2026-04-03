import SwiftUI
import UIKit

struct PastReportsView: View {
    @State private var savedReports: [SavedSFSTReport] = []

    private let reportsStorageKey = "saved_sfst_reports"

    var body: some View {
        List {
            if savedReports.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    Text("No saved summaries yet.")
                        .font(.headline)

                    Text("Generated SFST field note summaries will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .listRowBackground(Color.clear)
            } else {
                ForEach(savedReports) { report in
                    NavigationLink(destination: SavedSummaryDetailView(report: report)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(report.subjectName)
                                .font(.headline)

                            Text(formattedDateTime(report.createdAt))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteReports)
            }
        }
        .navigationTitle("Saved Summaries")
        .onAppear {
            loadReports()
        }
    }

    private func loadReports() {
        guard let data = UserDefaults.standard.data(forKey: reportsStorageKey) else {
            savedReports = []
            return
        }

        do {
            savedReports = try JSONDecoder().decode([SavedSFSTReport].self, from: data)
        } catch {
            savedReports = []
        }
    }

    private func deleteReports(at offsets: IndexSet) {
        savedReports.remove(atOffsets: offsets)

        do {
            let data = try JSONEncoder().encode(savedReports)
            UserDefaults.standard.set(data, forKey: reportsStorageKey)
        } catch {
            return
        }
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SavedSummaryDetailView: View {
    let report: SavedSFSTReport
    @State private var copiedMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(report.reportText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)

                Button(action: {
                    UIPasteboard.general.string = report.reportText
                    copiedMessage = "Summary copied to clipboard."
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy Summary")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }

                if !copiedMessage.isEmpty {
                    Text(copiedMessage)
                        .foregroundColor(.green)
                        .font(.subheadline)
                }
            }
            .padding()
        }
        .navigationTitle(report.subjectName)
    }
}
