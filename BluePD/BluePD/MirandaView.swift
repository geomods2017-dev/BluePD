import SwiftUI
import UIKit

struct MirandaView: View {
    enum MirandaLanguage: String, CaseIterable, Identifiable {
        case english = "English"
        case spanish = "Spanish"

        var id: String { rawValue }
    }

    @State private var selectedLanguage: MirandaLanguage = .english
    @State private var copiedMessage = ""

    private let englishMirandaWarning = """
You have the right to remain silent.

Anything you say can and will be used against you in a court of law.

You have the right to talk to a lawyer and have him or her present with you while you are being questioned.

If you cannot afford to hire a lawyer, one will be appointed to represent you before any questioning, if you wish.

You can decide at any time to exercise these rights and not answer any questions or make any statements.
"""

    private let spanishMirandaWarning = """
Tiene el derecho de permanecer en silencio.

Cualquier cosa que diga puede y será usada en su contra en un tribunal de justicia.

Tiene el derecho de hablar con un abogado y de tenerlo presente con usted mientras está siendo interrogado.

Si no puede pagar un abogado, se le nombrará uno para representarlo antes de cualquier interrogatorio, si así lo desea.

Puede decidir en cualquier momento ejercer estos derechos y no responder preguntas ni hacer declaraciones.
"""

    private var activeWarning: String {
        switch selectedLanguage {
        case .english:
            return englishMirandaWarning
        case .spanish:
            return spanishMirandaWarning
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(MirandaLanguage.allCases) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 12) {
                    Label("Miranda Warning", systemImage: "exclamationmark.shield.fill")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(activeWarning)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.blue.opacity(0.12))
                .cornerRadius(18)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Officer Reminder")
                        .font(.headline)

                    Text("Read the warning clearly, confirm understanding, and document the subject’s response.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    UIPasteboard.general.string = activeWarning
                    copiedMessage = "\(selectedLanguage.rawValue) Miranda warning copied."
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy \(selectedLanguage.rawValue) Warning")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }

                if !copiedMessage.isEmpty {
                    Text(copiedMessage)
                        .foregroundColor(.green)
                        .font(.subheadline)
                }
            }
            .padding()
        }
        .navigationTitle("Miranda")
    }
}
