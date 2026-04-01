import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard

                BluePDCard {
                    BluePDSectionHeader(title: "Quick Access", systemImage: "bolt.fill")

                    VStack(spacing: 12) {
                        NavigationLink(destination: MirandaView()) {
                            quickLinkCard(
                                title: "Miranda Warnings",
                                subtitle: "Fast access to Miranda guidance and readout.",
                                systemImage: "exclamationmark.bubble.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: SFSTView()) {
                            quickLinkCard(
                                title: "SFST Reports",
                                subtitle: "Document roadside testing with a cleaner workflow.",
                                systemImage: "car.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: PastReportsView()) {
                            quickLinkCard(
                                title: "Past Reports",
                                subtitle: "Review and manage previously saved reports.",
                                systemImage: "clock.arrow.circlepath"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                BluePDCard {
                    BluePDSectionHeader(title: "BluePD Tools", systemImage: "shield.fill")

                    VStack(spacing: 12) {
                        quickInfoCard(
                            title: "Case Law",
                            subtitle: "Search and review law enforcement-relevant cases.",
                            systemImage: "books.vertical.fill"
                        )

                        quickInfoCard(
                            title: "State Codes",
                            subtitle: "Browse statutes and code references by state.",
                            systemImage: "map.fill"
                        )

                        quickInfoCard(
                            title: "Evidence",
                            subtitle: "Store or review case-related evidence images.",
                            systemImage: "photo.on.rectangle.angled"
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(BluePDTheme.appBackground.ignoresSafeArea())
        .navigationTitle("BluePD")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        BluePDCard {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(BluePDTheme.accentSoft)
                        .frame(width: 58, height: 58)

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(BluePDTheme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("BluePD")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(BluePDTheme.primaryText)

                    Text("Law enforcement tools in one secure workspace.")
                        .font(.subheadline)
                        .foregroundColor(BluePDTheme.secondaryText)
                }

                Spacer()
            }

            Text("Access field tools, reports, statutes, and legal resources with a cleaner interface.")
                .font(.subheadline)
                .foregroundColor(BluePDTheme.secondaryText)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
    }

    private func quickLinkCard(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BluePDTheme.accentSoft)
                    .frame(width: 46, height: 46)

                Image(systemName: systemImage)
                    .foregroundColor(BluePDTheme.accent)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(BluePDTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(BluePDTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(BluePDTheme.tertiaryText)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func quickInfoCard(title: String, subtitle: String, systemImage: String) -> some View {
        BluePDInfoRow(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
