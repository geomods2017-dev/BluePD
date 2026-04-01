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
        ScrollView {
            VStack(spacing: 16) {
                topHeader
                quickActionsSection
                officerOverviewSection
                toolsOverviewSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("BluePD")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 7/255, green: 12/255, blue: 24/255),
                Color(red: 13/255, green: 23/255, blue: 40/255),
                Color(red: 18/255, green: 29/255, blue: 48/255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.blue.opacity(0.14))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("BluePD")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Law enforcement tools in one place")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.68))
                }

                Spacer()
            }

            Text(greetingLine)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.82))
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Quick Actions")

            VStack(spacing: 10) {
                NavigationLink(destination: MirandaView()) {
                    primaryActionRow(
                        title: "Miranda Warnings",
                        subtitle: "Fast access to Miranda guidance",
                        systemImage: "exclamationmark.bubble.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: SFSTView()) {
                    primaryActionRow(
                        title: "SFST Report",
                        subtitle: "Start or complete a sobriety report",
                        systemImage: "car.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: PastReportsView()) {
                    primaryActionRow(
                        title: "Past Reports",
                        subtitle: "Open previously saved reports",
                        systemImage: "clock.arrow.circlepath"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var officerOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Officer Overview")

            LazyVGrid(columns: columns, spacing: 12) {
                compactStatCard(
                    title: officerName.trimmedOrFallback("Not Set"),
                    subtitle: "Officer",
                    systemImage: "person.fill"
                )

                compactStatCard(
                    title: agencyName.trimmedOrFallback("Not Set"),
                    subtitle: "Agency",
                    systemImage: "building.2.fill"
                )

                compactStatCard(
                    title: officerUnit.trimmedOrFallback("Not Set"),
                    subtitle: "Unit",
                    systemImage: "shield.fill"
                )

                compactStatCard(
                    title: "Secure",
                    subtitle: "Access",
                    systemImage: "lock.shield.fill"
                )
            }
        }
    }

    private var toolsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Tools")

            VStack(spacing: 10) {
                compactToolRow(
                    title: "Case Law",
                    subtitle: "Recent legal updates and reference material",
                    systemImage: "books.vertical.fill"
                )

                compactToolRow(
                    title: "State Codes",
                    subtitle: "Criminal and traffic code references",
                    systemImage: "map.fill"
                )

                compactToolRow(
                    title: "Evidence",
                    subtitle: "Store and review case-related photos",
                    systemImage: "camera.viewfinder"
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
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
    }

    private func primaryActionRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.blue.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.64))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.32))
        }
        .padding(14)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private func compactToolRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.blue.opacity(0.10))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.64))
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
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.blue.opacity(0.10))
                )

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.60))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.055))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.white.opacity(0.06), lineWidth: 1)
    }

    private var innerCardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.white.opacity(0.045))
    }

    private var innerCardBorder: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
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
