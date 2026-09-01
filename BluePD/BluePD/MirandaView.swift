import SwiftUI
import UIKit

struct MirandaView: View {
    @State private var selectedLanguage: Language = .english
    @State private var subjectResponse: String = ""
    @State private var showCopied = false

    @State private var showPirtle = false
    @State private var pirtleResponse: String = ""

    @State private var shareFile: ShareableFile?

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
                pirtleToggleCard

                if showPirtle {
                    pirtleCard
                    pirtleAcknowledgmentSection
                }

                actionButtons

                if showCopied {
                    Text("Copied to clipboard")
                        .font(.caption)
                        .foregroundStyle(BluePDTheme.success)
                }
            }
            .padding()
        }
        .background(BluePDTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Miranda")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $shareFile) { file in
            ShareSheet(items: [file.url])
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Miranda Warning")
                .font(.title2.weight(.bold))
                .foregroundStyle(BluePDTheme.primaryText)

            Text("Read clearly, confirm understanding, and document the response.")
                .font(.subheadline)
                .foregroundStyle(BluePDTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bluePDInnerCard(cornerRadius: 18)
    }

    private var languageToggle: some View {
        HStack {
            Button(action: { selectedLanguage = .english }) {
                Text("English")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedLanguage == .english ? BluePDTheme.accent : BluePDTheme.cardFill)
                    .foregroundColor(selectedLanguage == .english ? .white : BluePDTheme.primaryText)
                    .cornerRadius(10)
            }

            Button(action: { selectedLanguage = .spanish }) {
                Text("Spanish")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedLanguage == .spanish ? BluePDTheme.accent : BluePDTheme.cardFill)
                    .foregroundColor(selectedLanguage == .spanish ? .white : BluePDTheme.primaryText)
                    .cornerRadius(10)
            }
        }
    }

    private var mirandaCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Miranda")
                .font(.headline)
                .foregroundStyle(BluePDTheme.primaryText)

            Text(currentMirandaText)
                .font(.title3)
                .foregroundStyle(BluePDTheme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bluePDInnerCard(cornerRadius: 18)
    }

    private var acknowledgmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Acknowledgment")
                .font(.headline)
                .foregroundStyle(BluePDTheme.primaryText)

            Text(currentAcknowledgmentQuestion)
                .foregroundStyle(BluePDTheme.secondaryText)

            TextField(
                "",
                text: $subjectResponse,
                prompt: Text("Subject response (e.g. Yes, No, Nods head)")
                    .foregroundColor(BluePDTheme.placeholderText)
            )
            .padding()
            .background(BluePDTheme.cardFill)
            .cornerRadius(12)
            .foregroundStyle(BluePDTheme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bluePDInnerCard(cornerRadius: 18)
    }

    private var pirtleToggleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Indiana Pirtle Advisement")
                        .font(.headline)
                        .foregroundStyle(BluePDTheme.primaryText)

                    Text("Use when requesting consent to search in Indiana in a custodial setting where Pirtle applies.")
                        .font(.subheadline)
                        .foregroundStyle(BluePDTheme.secondaryText)
                }

                Spacer()

                Toggle("", isOn: $showPirtle)
                    .labelsHidden()
                    .tint(BluePDTheme.accent)
            }

            if showPirtle {
                Text("Enabled")
                    .font(.caption)
                    .foregroundStyle(BluePDTheme.success)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bluePDInnerCard(cornerRadius: 18)
    }

    private var pirtleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Indiana Pirtle Advisement")
                .font(.headline)
                .foregroundStyle(BluePDTheme.primaryText)

            Text(currentPirtleText)
                .font(.title3)
                .foregroundStyle(BluePDTheme.primaryText)

            Text("Confirm current Indiana law, agency policy, and prosecutor guidance before operational use.")
                .font(.caption)
                .foregroundStyle(BluePDTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bluePDInnerCard(cornerRadius: 18)
    }

    private var pirtleAcknowledgmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pirtle Acknowledgment")
                .font(.headline)
                .foregroundStyle(BluePDTheme.primaryText)

            Text(currentPirtleQuestion)
                .foregroundStyle(BluePDTheme.secondaryText)

            TextField(
                "",
                text: $pirtleResponse,
                prompt: Text("Subject response (e.g. Yes, No, Wants attorney, Refuses)")
                    .foregroundColor(BluePDTheme.placeholderText)
            )
            .padding()
            .background(BluePDTheme.cardFill)
            .cornerRadius(12)
            .foregroundStyle(BluePDTheme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bluePDInnerCard(cornerRadius: 18)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                UIPasteboard.general.string = buildOutput()
                showCopied = true
            } label: {
                Text("Copy Warning(s) + Response")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BluePDPrimaryButtonStyle())

            Button {
                shareTranscript()
            } label: {
                Label("Share / Export", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BluePDSecondaryButtonStyle())

            Button("Clear Responses") {
                subjectResponse = ""
                pirtleResponse = ""
                showCopied = false
            }
            .buttonStyle(BluePDTextButtonStyle())
        }
    }

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

    private var currentPirtleText: String {
        switch selectedLanguage {
        case .english:
            return """
You have the right to require that a search warrant be obtained before any search of your residence, vehicle, or other property covered by law.
You have the right to refuse consent to such a search.
You have the right to consult with an attorney before deciding whether to give consent to such a search.
"""
        case .spanish:
            return """
Usted tiene el derecho de exigir que se obtenga una orden de registro antes de cualquier registro de su residencia, vehículo u otra propiedad cubierta por la ley.
Usted tiene el derecho de negarse a dar su consentimiento para dicho registro.
Usted tiene el derecho de consultar con un abogado antes de decidir si dará su consentimiento para dicho registro.
"""
        }
    }

    private var currentPirtleQuestion: String {
        switch selectedLanguage {
        case .english:
            return "Do you understand these rights regarding consent to search?"
        case .spanish:
            return "¿Entiende estos derechos con respecto al consentimiento para registrar?"
        }
    }

    private func buildOutput() -> String {
        var output = """
Miranda Warning Given:
\(currentMirandaText)

Miranda Acknowledgment:
\(currentAcknowledgmentQuestion)

Response:
\(subjectResponse.isEmpty ? "No response documented" : subjectResponse)
"""

        if showPirtle {
            output += """


Indiana Pirtle Advisement Given:
\(currentPirtleText)

Pirtle Acknowledgment:
\(currentPirtleQuestion)

Response:
\(pirtleResponse.isEmpty ? "No response documented" : pirtleResponse)
"""
        }

        return output
    }

    private func shareTranscript() {
        guard let data = PDFReportBuilder.makeTextReportPDF(
            title: "Miranda Advisement",
            subtitle: selectedLanguage == .english ? "English" : "Spanish",
            body: buildOutput()
        ), let url = PDFReportBuilder.writeTemporaryPDF(data: data, suggestedName: "Miranda Advisement") else {
            return
        }

        shareFile = ShareableFile(url: url)
    }
}
