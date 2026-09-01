import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cloudSync: CloudSyncManager

    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("officerUnit") private var officerUnit: String = ""
    // Re-declaring this key (unused directly) makes SwiftUI re-render Home whenever
    // Daylight Mode is toggled in Settings, since BluePDTheme reads it live rather than
    // through a published value of its own.
    @AppStorage(BluePDTheme.daylightModeKey) private var daylightModeEnabled: Bool = false

    @State private var savedReports: [SavedSFSTReport] = SavedSFSTReportStore.load()
    @State private var hasRunInitialSync = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                commandHeader
                quickActionsSection
                statusSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(BluePDTheme.appBackground.ignoresSafeArea())
        .navigationTitle("BluePD")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: savedReports) { newValue in
            SavedSFSTReportStore.save(newValue)
        }
        .task {
            guard !hasRunInitialSync else { return }
            hasRunInitialSync = true
            await runInitialSync()
        }
    }

    private var commandHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                BluePDIconContainer(
                    systemImage: "shield.checkered",
                    size: 56,
                    iconSize: 22
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("BluePD")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(BluePDTheme.primaryText)

                    Text("Field-ready law enforcement tools")
                        .font(.subheadline)
                        .foregroundStyle(BluePDTheme.secondaryText)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("ON DUTY")
                    .font(.caption.weight(.bold))
                    .kerning(1.2)
                    .foregroundStyle(BluePDTheme.accent)

                Text(greetingLine)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(BluePDTheme.primaryText.opacity(0.92))
            }
        }
        .padding(20)
        .bluePDCard(cornerRadius: 24)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Quick Access")

            VStack(spacing: 12) {
                NavigationLink(destination: MirandaView()) {
                    primaryActionRow(
                        title: "Miranda Warnings",
                        subtitle: "Immediate access to warning guidance",
                        systemImage: "text.bubble.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: SFSTView(savedReports: $savedReports)) {
                    primaryActionRow(
                        title: "SFST Report",
                        subtitle: "Start, review, or complete a report",
                        systemImage: "car.side.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: SavedReportsView(savedReports: $savedReports)) {
                    primaryActionRow(
                        title: "Saved Reports",
                        subtitle: savedReportsSubtitle,
                        systemImage: "doc.text.fill"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Officer Profile")

            LazyVGrid(columns: columns, spacing: 14) {
                compactStatCard(
                    title: officerName.trimmedOrFallback("No Name"),
                    subtitle: "Officer",
                    systemImage: "person.crop.rectangle.fill"
                )

                compactStatCard(
                    title: agencyName.trimmedOrFallback("No Agency"),
                    subtitle: "Agency",
                    systemImage: "building.columns.fill"
                )

                compactStatCard(
                    title: officerUnit.trimmedOrFallback("No Unit"),
                    subtitle: "Unit",
                    systemImage: "shield.fill"
                )

                syncStatCard
            }
        }
    }

    private var syncStatCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            BluePDIconContainer(
                systemImage: cloudSync.status.isHealthy ? "icloud.fill" : "icloud.slash.fill",
                size: 44,
                iconSize: 17
            )

            Text(cloudSync.status.isHealthy ? "iCloud" : "Sync Off")
                .font(.title3.weight(.semibold))
                .foregroundStyle(BluePDTheme.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.80)

            Text(cloudSync.status.displayText)
                .font(.caption)
                .foregroundStyle(BluePDTheme.secondaryText)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .bluePDInnerCard(cornerRadius: 22)
    }

    private var greetingLine: String {
        let officer = officerName.trimmedOrFallback("Officer")
        let agency = agencyName.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = officerUnit.trimmingCharacters(in: .whitespacesAndNewlines)

        if !agency.isEmpty && !unit.isEmpty {
            return "\(officer) • \(agency) • \(unit)"
        } else if !agency.isEmpty {
            return "\(officer) • \(agency)"
        } else if !unit.isEmpty {
            return "\(officer) • \(unit)"
        } else {
            return officer
        }
    }

    private var savedReportsSubtitle: String {
        let count = savedReports.count
        return count == 0 ? "No reports saved yet" : "\(count) report\(count == 1 ? "" : "s") saved"
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(BluePDTheme.accent)
                .frame(width: 5, height: 24)

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(BluePDTheme.primaryText)

            Spacer()
        }
        .padding(.horizontal, 2)
    }

    private func primaryActionRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            BluePDIconContainer(
                systemImage: systemImage,
                size: 46,
                iconSize: 18
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(BluePDTheme.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .bluePDInnerCard(cornerRadius: 20)
    }

    private func compactStatCard(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            BluePDIconContainer(
                systemImage: systemImage,
                size: 44,
                iconSize: 17
            )

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(BluePDTheme.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.80)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(BluePDTheme.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .bluePDInnerCard(cornerRadius: 22)
    }

    @MainActor
    private func runInitialSync() async {
        await cloudSync.checkAccountStatus()
        guard cloudSync.status.isHealthy else { return }

        let remoteReports = await cloudSync.pullAll(kind: .report, as: SavedSFSTReport.self)
        let merged = CloudSyncManager.mergeAdditively(local: savedReports, remote: remoteReports)

        if merged.count != savedReports.count {
            savedReports = merged
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(CloudSyncManager())
    }
}
