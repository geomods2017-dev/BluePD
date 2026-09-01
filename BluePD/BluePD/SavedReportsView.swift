import SwiftUI

struct SavedReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var cloudSync: CloudSyncManager

    @Binding var savedReports: [SavedSFSTReport]
    @State private var selectedReport: SavedSFSTReport?

    private let freeReportLimit = 3

    private var hasReachedFreeLimit: Bool {
        !storeManager.isPro && savedReports.count >= freeReportLimit
    }

    private var reportsStatusTitle: String {
        storeManager.isPro ? "BluePD Pro Active" : "Free Saved Reports"
    }

    private var reportsStatusSubtitle: String {
        storeManager.isPro
            ? "Unlimited saved reports available"
            : "\(savedReports.count)/\(freeReportLimit) reports used"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BluePDTheme.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    reportsStatusBanner

                    if savedReports.isEmpty {
                        BluePDEmptyState(
                            systemImage: "doc.text.magnifyingglass",
                            title: "No Saved Reports",
                            message: "Generated SFST reports will appear here."
                        )
                        .padding(.horizontal, 16)
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(savedReports) { report in
                                Button {
                                    selectedReport = report
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(report.subjectName.isEmpty ? "Unnamed Subject" : report.subjectName)
                                            .font(.headline)
                                            .foregroundColor(BluePDTheme.primaryText)

                                        Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(BluePDTheme.secondaryText)
                                    }
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(BluePDTheme.cardFill)
                            }
                            .onDelete { offsets in
                                deleteReports(at: offsets)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Saved Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BluePDTheme.primaryText)
                }
            }
            .sheet(item: $selectedReport) { report in
                SavedReportDetailView(report: report)
            }
        }
    }

    private var reportsStatusBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: storeManager.isPro ? "checkmark.seal.fill" : "folder.fill")
                .foregroundColor(storeManager.isPro ? BluePDTheme.success : BluePDTheme.accent)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(reportsStatusTitle)
                    .font(.headline)
                    .foregroundColor(BluePDTheme.primaryText)

                Text(reportsStatusSubtitle)
                    .font(.caption)
                    .foregroundColor(BluePDTheme.secondaryText)

                if hasReachedFreeLimit {
                    Text("Free limit reached. Upgrade to BluePD Pro for unlimited saved reports.")
                        .font(.caption)
                        .foregroundColor(BluePDTheme.warning)
                }
            }

            Spacer()
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 18)
        .padding(.horizontal)
    }

    private func deleteReports(at offsets: IndexSet) {
        let removed = offsets.map { savedReports[$0] }
        savedReports.remove(atOffsets: offsets)

        for report in removed {
            Task {
                await cloudSync.delete(id: report.id, kind: .report)
            }
        }
    }
}

struct SavedReportDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let report: SavedSFSTReport

    @State private var shareFile: ShareableFile?
    @State private var exportErrorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(report.subjectName.isEmpty ? "Unnamed Subject" : report.subjectName)
                        .font(.headline)
                        .foregroundColor(BluePDTheme.primaryText)

                    Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(BluePDTheme.secondaryText)

                    Divider()
                        .overlay(BluePDTheme.innerCardStroke)

                    Text(report.reportText)
                        .foregroundColor(BluePDTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let exportErrorMessage {
                        Text(exportErrorMessage)
                            .font(.caption)
                            .foregroundColor(BluePDTheme.danger)
                    }
                }
                .padding()
            }
            .background(
                BluePDTheme.appBackground
                    .ignoresSafeArea()
            )
            .navigationTitle("Report Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        exportPDF()
                    } label: {
                        Label("Export / Share", systemImage: "square.and.arrow.up")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BluePDTheme.primaryText)
                }
            }
            .sheet(item: $shareFile) { file in
                ShareSheet(items: [file.url])
            }
        }
    }

    private func exportPDF() {
        exportErrorMessage = nil

        let subjectLine = report.subjectName.isEmpty ? "Unnamed Subject" : report.subjectName
        let subtitle = "Subject: \(subjectLine) • \(report.createdAt.formatted(date: .abbreviated, time: .shortened))"

        guard let data = PDFReportBuilder.makeTextReportPDF(
            title: "SFST Report",
            subtitle: subtitle,
            body: report.reportText,
            generatedAt: report.createdAt
        ), let url = PDFReportBuilder.writeTemporaryPDF(data: data, suggestedName: "SFST Report - \(subjectLine)") else {
            exportErrorMessage = "Could not generate PDF. Try again."
            return
        }

        shareFile = ShareableFile(url: url)
    }
}
