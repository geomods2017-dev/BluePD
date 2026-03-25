import SwiftUI

struct MirandaView: View {
    let mirandaText = """
You have the right to remain silent.
Anything you say can and will be used against you in a court of law.
You have the right to talk to a lawyer and have the lawyer with you during questioning.
If you cannot afford a lawyer, one will be appointed to represent you before any questioning if you wish.
You can decide at any time to exercise these rights and not answer any questions or make any statements.
"""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.03, green: 0.07, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("BLUE PD")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue.opacity(0.9))
                            .tracking(2)

                        Text("Miranda Card")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("Field Advisement")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(.blue)

                            Text("Official Warning")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Spacer()

                            Text("READ VERBATIM")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.18))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }

                        Divider()
                            .overlay(Color.blue.opacity(0.35))

                        Text(mirandaText)
                            .font(.system(size: 22, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 12) {
                            Label("Custodial Use", systemImage: "person.crop.rectangle")
                            Label("Document Time Given", systemImage: "clock")
                        }
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.65))
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.blue.opacity(0.45), lineWidth: 1.2)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Field Notes")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        MirandaNoteRow(text: "Read clearly and exactly as written.")
                        MirandaNoteRow(text: "Document time, location, and involved officers.")
                        MirandaNoteRow(text: "Document waiver, invocation, or refusal.")
                        MirandaNoteRow(text: "Follow department policy and current state law.")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.04))
                    )

                    HStack(spacing: 12) {
                        MirandaActionButton(title: "Copy", icon: "doc.on.doc")
                        MirandaActionButton(title: "Large Text", icon: "textformat.size")
                        MirandaActionButton(title: "Notes", icon: "square.and.pencil")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

struct MirandaNoteRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.16))
                    .frame(width: 28, height: 28)

                Image(systemName: "checkmark.shield")
                    .foregroundColor(.blue)
                    .font(.system(size: 14, weight: .bold))
            }

            Text(text)
                .foregroundColor(.white.opacity(0.92))
                .font(.body)

            Spacer()
        }
    }
}

struct MirandaActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue.opacity(0.16))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
