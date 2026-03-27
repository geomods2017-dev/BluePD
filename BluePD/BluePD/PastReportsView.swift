import SwiftUI

struct PastReportsView: View {
    @State private var savedReports: [SavedSFSTReport] = []

    private let reportsStorageKey = "saved_sfst_reports"

    var body: some View {
        List {
            if savedReports.isEmpty {
                Text("No saved SFST reports yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(savedReports) { report in
                    NavigationLink(destination: PastReportDetailView(report: report)) {
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
        .navigationTitle("Past Reports")
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

struct PastReportDetailView: View {
    let report: SavedSFSTReport

    var body: some View {
        ScrollView {
            Text(report.reportText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .textSelection(.enabled)
        }
        .navigationTitle(report.subjectName)
    }
}
