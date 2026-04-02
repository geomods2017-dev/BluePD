import SwiftUI

struct HomeView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("officerUnit") private var officerUnit: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                commandHeader
                quickActionsSection
                officerOverviewSection
                toolsOverviewSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("BluePD")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 3/255, green: 8/255, blue: 18/255),
                Color(red: 7/255, green: 16/255, blue: 30/255),
                Color(red: 12/255, green: 24/255, blue: 42/255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var commandHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.blue.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                        )

                    Image(systemName: "shield.checkered")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.blue)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 3) {
                    Text("BluePD")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Field-ready law enforcement tools")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.66))
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("ON DUTY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .kerning(1.1)
                    .foregroundColor(.blue.opacity(0.92))

                Text(greetingLine)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.88))
            }
        }
        .padding(18)
        .background(outerCardBackground)
        .overlay(outerCardBorder)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Quick Access")

            VStack(spacing: 10) {
                NavigationLink(destination: MirandaView()) {
                    primaryActionRow(
                        title: "Miranda Warnings",
                        subtitle: "Immediate access to warning guidance",
                        systemImage: "text.bubble.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: SFSTView()) {
                    primaryActionRow(
                        title: "SFST Report",
                        subtitle: "Start, review, or complete a report",
                        systemImage: "car.side.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: PastReportsView()) {
                    primaryActionRow(
                        title: "Past Reports",
                        subtitle: "Review previously generated reports",
                        systemImage: "doc.text.fill"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var officerOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Officer Profile")

            LazyVGrid(columns: columns, spacing: 12) {
                compactStatCard(
                    title: officerName.trimmedOrFallback("Not Set"),
                    subtitle: "Officer",
                    systemImage: "person.crop.rectangle.fill"
                )

                compactStatCard(
                    title: agencyName.trimmedOrFallback("Not Set"),
                    subtitle: "Agency",
                    systemImage: "building.columns.fill"
                )

                compactStatCard(
                    title: officerUnit.trimmedOrFallback("Not Set"),
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
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Operational Tools")

            VStack(spacing: 10) {
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
        HStack {
            Rectangle()
                .fill(Color.blue.opacity(0.9))
                .frame(width: 4, height: 18)
                .cornerRadius(3)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 2)
    }

    private func primaryActionRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.blue.opacity(0.28), lineWidth: 1)
                    )

                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.62))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.30))
        }
        .padding(14)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private func compactToolRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.blue.opacity(0.24), lineWidth: 1)
                    )

                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.62))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private func compactStatCard(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.blue.opacity(0.24), lineWidth: 1)
                    )

                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .frame(width: 36, height: 36)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.58))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private var outerCardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.06),
                        Color.white.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var outerCardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.blue.opacity(0.18), lineWidth: 1)
    }

    private var innerCardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.045),
                        Color.white.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var innerCardBorder: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.06), lineWidth: 1)
    }
}

private extension String {
    func trimmedOrFallback(_ fallback: String) -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
