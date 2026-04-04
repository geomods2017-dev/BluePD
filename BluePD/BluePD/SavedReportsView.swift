import SwiftUI

struct SavedReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager

    @Binding var savedReports: [SavedSFSTReport]
    @State private var selectedReport: SavedSFSTReport?

    private let freeReportLimit = 3

    private let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 3/255, green: 8/255, blue: 18/255),
            Color(red: 7/255, green: 16/255, blue: 30/255),
            Color(red: 12/255, green: 24/255, blue: 42/255)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    private var hasReachedFreeLimit: Bool {
        !storeManager.isPro && savedReports.count >= freeReportLimit
    }

    private var reportsStatusTitle: String {
        if storeManager.isPro {
            return "BluePD Pro Active"
        } else {
            return "Free Saved Reports"
        }
    }

    private var reportsStatusSubtitle: String {
        if storeManager.isPro {
            return "Unlimited saved reports available"
        } else {
            return "\(savedReports.count)/\(freeReportLimit) reports used"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    reportsStatusBanner

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
                .padding(.top, 8)
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

    private var reportsStatusBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: storeManager.isPro ? "checkmark.seal.fill" : "folder.fill")
                .foregroundColor(storeManager.isPro ? .green : .blue)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(reportsStatusTitle)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(reportsStatusSubtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.72))

                if hasReachedFreeLimit {
                    Text("Free limit reached. Upgrade to BluePD Pro for unlimited saved reports.")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.95))
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .padding(.horizontal)
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
