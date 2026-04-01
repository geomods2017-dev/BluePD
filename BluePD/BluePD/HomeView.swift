import SwiftUI

struct HomeView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("officerUnit") private var officerUnit: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard
                statusCard
                quickAccessCard
                toolsCard
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 7/255, green: 12/255, blue: 24/255),
                    Color(red: 13/255, green: 23/255, blue: 40/255),
                    Color(red: 18/255, green: 29/255, blue: 48/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("BluePD")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue.opacity(0.16))
                        .frame(width: 58, height: 58)

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("BluePD")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Secure law enforcement tools")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer()
            }

            Text("Access reports, legal tools, evidence features, and state resources from one clean workspace.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("Officer Status")
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "person.crop.rectangle.fill")
                    .foregroundColor(.blue)
            }

            HStack(spacing: 12) {
                statusTile(
                    title: officerName.isEmpty ? "Not Set" : officerName,
                    subtitle: "Officer",
                    systemImage: "person.fill"
                )

                statusTile(
                    title: agencyName.isEmpty ? "Not Set" : agencyName,
                    subtitle: "Agency",
                    systemImage: "building.2.fill"
                )
            }

            HStack(spacing: 12) {
                statusTile(
                    title: officerUnit.isEmpty ? "Not Set" : officerUnit,
                    subtitle: "Unit",
                    systemImage: "shield.fill"
                )

                statusTile(
                    title: "Secure",
                    subtitle: "Access",
                    systemImage: "lock.shield.fill"
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var quickAccessCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("Quick Access")
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.blue)
            }

            VStack(spacing: 12) {
                NavigationLink(destination: MirandaView()) {
                    quickAccessRow(
                        title: "Miranda Warnings",
                        subtitle: "Read and reference Miranda guidance quickly.",
                        systemImage: "exclamationmark.bubble.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: SFSTView()) {
                    quickAccessRow(
                        title: "SFST Report",
                        subtitle: "Start or complete a standardized field sobriety report.",
                        systemImage: "car.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: PastReportsView()) {
                    quickAccessRow(
                        title: "Past Reports",
                        subtitle: "Review previously saved SFST reports.",
                        systemImage: "clock.arrow.circlepath"
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var toolsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("BluePD Tools")
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(.blue)
            }

            VStack(spacing: 12) {
                toolRow(
                    title: "Case Law",
                    subtitle: "Browse key legal updates relevant to field operations.",
                    systemImage: "books.vertical.fill"
                )

                toolRow(
                    title: "State Codes",
                    subtitle: "Open criminal and traffic code references by state.",
                    systemImage: "map.fill"
                )

                toolRow(
                    title: "Evidence",
                    subtitle: "Store and manage case-related photos and visual material.",
                    systemImage: "camera.viewfinder"
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func quickAccessRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func toolRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func statusTile(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 42, height: 42)

                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .font(.headline)
            }

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.68))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
