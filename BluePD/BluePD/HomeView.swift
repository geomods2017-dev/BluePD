import SwiftUI

struct HomeView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("officerUnit") private var officerUnit: String = ""

    @State private var savedReports: [SavedSFSTReport] = []

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                commandHeader
                quickActionsSection
                officerOverviewSection
                toolsOverviewSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(BluePDTheme.appBackground.ignoresSafeArea())
        .navigationTitle("BluePD")
        .navigationBarTitleDisplayMode(.inline)
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
                        title: "Past Reports",
                        subtitle: "Review previously saved SFST reports",
                        systemImage: "doc.text.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: QuickCardsView()) {
                    primaryActionRow(
                        title: "Quick Cards",
                        subtitle: "Open saved custom reference cards",
                        systemImage: "rectangle.stack.text.card.fill"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var officerOverviewSection: some View {
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

                compactStatCard(
                    title: "Secured",
                    subtitle: "Access",
                    systemImage: "lock.shield.fill"
                )
            }
        }
    }

    private var toolsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Operational Tools")

            VStack(spacing: 12) {
                compactToolRow(
                    title: "Case Law",
                    subtitle: "Recent legal updates and searchable references",
                    systemImage: "book.closed.fill"
                )

                compactToolRow(
                    title: "State Codes",
                    subtitle: "Traffic and criminal statute references",
                    systemImage: "doc.text.magnifyingglass"
                )

                compactToolRow(
                    title: "Evidence",
                    subtitle: "Store and review case-related images",
                    systemImage: "camera.fill"
                )

                compactToolRow(
                    title: "Quick Cards",
                    subtitle: "Custom reminders, notes, and reference cards",
                    systemImage: "rectangle.stack.text.card.fill"
                )
            }
        }
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

    private func compactToolRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            BluePDIconContainer(
                systemImage: systemImage,
                size: 50,
                iconSize: 20
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 22)
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
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
