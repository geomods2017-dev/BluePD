import SwiftUI

struct MirandaView: View {
    @State private var selectedLanguage: Language = .english
    @State private var subjectResponse: String = ""
    @State private var showCopied = false

    enum Language {
        case english
        case spanish
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                headerCard

                languageToggle

                mirandaCard

                acknowledgmentSection

                actionButtons

                if showCopied {
                    Text("Copied to clipboard")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 7/255, green: 12/255, blue: 24/255),
                    Color(red: 13/255, green: 23/255, blue: 40/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Miranda")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: UI Sections

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Miranda Warning")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text("Read clearly and confirm understanding.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
        )
    }

    private var languageToggle: some View {
        HStack {
            Button(action: { selectedLanguage = .english }) {
                Text("English")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedLanguage == .english ? Color.blue : Color.white.opacity(0.08))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: { selectedLanguage = .spanish }) {
                Text("Spanish")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedLanguage == .spanish ? Color.blue : Color.white.opacity(0.08))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    private var mirandaCard: some View {
        Text(currentMirandaText)
            .font(.title3)
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.05))
            )
    }

    private var acknowledgmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Acknowledgment")
                .font(.headline)
                .foregroundColor(.white)

            Text(currentAcknowledgmentQuestion)
                .foregroundColor(.white.opacity(0.85))

            TextField("Subject response (e.g. Yes, No, Nods head)", text: $subjectResponse)
                .padding()
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button("Copy Miranda + Response") {
                UIPasteboard.general.string = buildOutput()
                showCopied = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Button("Clear Response") {
                subjectResponse = ""
                showCopied = false
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.08))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }

    // MARK: Logic

    private var currentMirandaText: String {
        switch selectedLanguage {
        case .english:
            return """
You have the right to remain silent.
Anything you say can and will be used against you in a court of law.
You have the right to talk to a lawyer and have them present with you while you are being questioned.
If you cannot afford a lawyer, one will be appointed to represent you before any questioning if you wish.
"""
        case .spanish:
            return """
Tiene el derecho de permanecer en silencio.
Cualquier cosa que diga puede y será usada en su contra en una corte de ley.
Tiene el derecho de hablar con un abogado y tenerlo presente durante el interrogatorio.
Si no puede pagar un abogado, se le asignará uno antes de cualquier interrogatorio si así lo desea.
"""
        }
    }

    private var currentAcknowledgmentQuestion: String {
        switch selectedLanguage {
        case .english:
            return "Do you understand your rights as I have read them to you?"
        case .spanish:
            return "¿Entiende los derechos que le he leído?"
        }
    }

    private func buildOutput() -> String {
        return """
Miranda Warning Given:
\(currentMirandaText)

Acknowledgment:
\(currentAcknowledgmentQuestion)

Response:
\(subjectResponse.isEmpty ? "No response documented" : subjectResponse)
"""
    }
}
