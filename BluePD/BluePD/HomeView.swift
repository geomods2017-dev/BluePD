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
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("BluePD")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 2/255, green: 7/255, blue: 18/255),
                Color(red: 7/255, green: 17/255, blue: 31/255),
                Color(red: 10/255, green: 24/255, blue: 44/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var commandHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.blue.opacity(0.25), lineWidth: 1)
                        )

                    Image(systemName: "shield.checkered")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(BluePDPalette.accent)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("BluePD")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(BluePDPalette.primaryText)

                    Text("Field-ready law enforcement tools")
                        .font(.subheadline)
                        .foregroundStyle(BluePDPalette.secondaryText)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("ON DUTY")
                    .font(.caption.weight(.bold))
                    .kerning(1.2)
                    .foregroundStyle(BluePDPalette.accent)

                Text(greetingLine)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(BluePDPalette.primaryText.opacity(0.92))
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
                .fill(BluePDPalette.accent)
                .frame(width: 5, height: 24)

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(BluePDPalette.primaryText)

            Spacer()
        }
        .padding(.horizontal, 2)
    }

    private func primaryActionRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            iconContainer(systemImage: systemImage, size: 46, iconSize: 18)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDPalette.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BluePDPalette.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(BluePDPalette.tertiaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .bluePDInnerCard(cornerRadius: 20)
    }

    private func compactToolRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            iconContainer(systemImage: systemImage, size: 50, iconSize: 20)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BluePDPalette.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BluePDPalette.secondaryText)
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
            iconContainer(systemImage: systemImage, size: 44, iconSize: 17)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(BluePDPalette.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.80)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(BluePDPalette.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .bluePDInnerCard(cornerRadius: 22)
    }

    private func iconContainer(systemImage: String, size: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.blue.opacity(0.22), lineWidth: 1)
                )

            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(BluePDPalette.accent)
        }
        .frame(width: size, height: size)
    }
}

private enum BluePDPalette {
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.74)
    static let tertiaryText = Color.white.opacity(0.38)
    static let accent = Color(red: 0.10, green: 0.56, blue: 1.00)
}

private struct BluePDCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.070),
                                Color.white.opacity(0.032)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
    }
}

private struct BluePDInnerCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.050),
                                Color.white.opacity(0.028)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.065), lineWidth: 1)
            )
    }
}

private extension View {
    func bluePDCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(BluePDCardModifier(cornerRadius: cornerRadius))
    }

    func bluePDInnerCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(BluePDInnerCardModifier(cornerRadius: cornerRadius))
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
