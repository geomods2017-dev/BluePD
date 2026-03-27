import SwiftUI
import UIKit

struct SFSTView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("badgeNumber") private var badgeNumber: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""

    @State private var subjectName = ""
    @State private var incidentDate = Date()
    @State private var incidentTime = Date()
    @State private var location = ""
    @State private var roadSurface = ""
    @State private var lighting = ""
    @State private var weather = ""
    @State private var footwear = ""
    @State private var medicalConditions = ""
    @State private var officerNotes = ""

    @State private var hgnSmoothPursuitLeft = false
    @State private var hgnSmoothPursuitRight = false
    @State private var hgnMaxDeviationLeft = false
    @State private var hgnMaxDeviationRight = false
    @State private var hgnOnset45Left = false
    @State private var hgnOnset45Right = false

    @State private var watCannotBalance = false
    @State private var watStartsTooSoon = false
    @State private var watStopsWalking = false
    @State private var watMissesHeelToToe = false
    @State private var watStepsOffLine = false
    @State private var watUsesArms = false
    @State private var watImproperTurn = false
    @State private var watWrongStepCount = false

    @State private var olsSways = false
    @State private var olsUsesArms = false
    @State private var olsHops = false
    @State private var olsFootDown = false

    @State private var generatedSummary = ""
    @State private var copiedMessage = ""
    @State private var savedMessage = ""

    @FocusState private var notesFieldFocused: Bool

    private let reportsStorageKey = "saved_sfst_reports"

    var hgnCount: Int {
        [
            hgnSmoothPursuitLeft,
            hgnSmoothPursuitRight,
            hgnMaxDeviationLeft,
            hgnMaxDeviationRight,
            hgnOnset45Left,
            hgnOnset45Right
        ].filter { $0 }.count
    }

    var watCount: Int {
        [
            watCannotBalance,
            watStartsTooSoon,
            watStopsWalking,
            watMissesHeelToToe,
            watStepsOffLine,
            watUsesArms,
            watImproperTurn,
            watWrongStepCount
        ].filter { $0 }.count
    }

    var olsCount: Int {
        [
            olsSways,
            olsUsesArms,
            olsHops,
            olsFootDown
        ].filter { $0 }.count
    }

    var body: some View {
        Form {
            Section("Subject / Incident Information") {
                TextField("Subject Name", text: $subjectName)

                DatePicker(
                    "Incident Date",
                    selection: $incidentDate,
                    displayedComponents: [.date]
                )

                DatePicker(
                    "Incident Time",
                    selection: $incidentTime,
                    displayedComponents: [.hourAndMinute]
                )

                TextField("Location", text: $location)
            }

            Section("Scene Conditions") {
                TextField("Road / Surface Condition", text: $roadSurface)
                TextField("Lighting", text: $lighting)
                TextField("Weather", text: $weather)
                TextField("Footwear", text: $footwear)
                TextField("Medical / Physical Limitations", text: $medicalConditions)
            }

            Section("HGN Instructions") {
                Text("• Confirm the subject understands instructions.")
                Text("• Check for equal tracking and equal pupil size.")
                Text("• Use a stimulus approximately 12–15 inches from the face and slightly above eye level.")
                Text("• Instruct the subject to follow the stimulus with the eyes only and keep the head still.")
                Text("• Observe each eye for the standardized clues.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section("HGN Clues — Total: \(hgnCount)/6") {
                Toggle("Lack of Smooth Pursuit — Left Eye", isOn: $hgnSmoothPursuitLeft)
                Toggle("Lack of Smooth Pursuit — Right Eye", isOn: $hgnSmoothPursuitRight)
                Toggle("Distinct and Sustained Nystagmus at Maximum Deviation — Left Eye", isOn: $hgnMaxDeviationLeft)
                Toggle("Distinct and Sustained Nystagmus at Maximum Deviation — Right Eye", isOn: $hgnMaxDeviationRight)
                Toggle("Onset of Nystagmus Prior to 45 Degrees — Left Eye", isOn: $hgnOnset45Left)
                Toggle("Onset of Nystagmus Prior to 45 Degrees — Right Eye", isOn: $hgnOnset45Right)
            }

            Section("Walk-and-Turn Instructions") {
                Text("• Place the left foot on the line.")
                Text("• Place the right foot in front of the left foot, heel-to-toe.")
                Text("• Keep arms at sides and maintain that position while instructions are given.")
                Text("• Do not begin until told to start.")
                Text("• Take 9 heel-to-toe steps, turn using a series of small steps, and take 9 heel-to-toe steps back.")
                Text("• Count steps out loud and watch the feet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section("Walk-and-Turn Clues — Total: \(watCount)/8") {
                Toggle("Cannot Keep Balance During Instructions", isOn: $watCannotBalance)
                Toggle("Starts Too Soon", isOn: $watStartsTooSoon)
                Toggle("Stops While Walking", isOn: $watStopsWalking)
                Toggle("Misses Heel-to-Toe", isOn: $watMissesHeelToToe)
                Toggle("Steps Off Line", isOn: $watStepsOffLine)
                Toggle("Uses Arms for Balance", isOn: $watUsesArms)
                Toggle("Improper Turn", isOn: $watImproperTurn)
                Toggle("Incorrect Number of Steps", isOn: $watWrongStepCount)
            }

            Section("One-Leg Stand Instructions") {
                Text("• Stand with feet together and arms at sides.")
                Text("• Raise one foot approximately 6 inches off the ground.")
                Text("• Keep the raised foot parallel to the ground.")
                Text("• Look at the raised foot and count out loud as instructed.")
                Text("• Continue until told to stop.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section("One-Leg Stand Clues — Total: \(olsCount)/4") {
                Toggle("Sways While Balancing", isOn: $olsSways)
                Toggle("Uses Arms for Balance", isOn: $olsUsesArms)
                Toggle("Hops", isOn: $olsHops)
                Toggle("Puts Foot Down", isOn: $olsFootDown)
            }

            Section("Officer Notes") {
                TextEditor(text: $officerNotes)
                    .frame(minHeight: 140)
                    .focused($notesFieldFocused)
            }

            Section("Quick Totals") {
                Text("HGN: \(hgnCount) / 6")
                Text("Walk-and-Turn: \(watCount) / 8")
                Text("One-Leg Stand: \(olsCount) / 4")
            }

            Section {
                Button("Generate Full Report") {
                    notesFieldFocused = false
                    generatedSummary = buildSummary()
                    copiedMessage = ""
                    savedMessage = ""
                }

                if !generatedSummary.isEmpty {
                    Button("Copy Report") {
                        UIPasteboard.general.string = generatedSummary
                        copiedMessage = "Report copied to clipboard."
                        savedMessage = ""
                        notesFieldFocused = false
                    }

                    Button("Save Report") {
                        saveCurrentReport()
                        copiedMessage = ""
                        notesFieldFocused = false
                    }
                }

                Button("Dismiss Keyboard") {
                    notesFieldFocused = false
                }

                Button("Reset SFST Form", role: .destructive) {
                    resetForm()
                }
            }

            if !copiedMessage.isEmpty {
                Section {
                    Text(copiedMessage)
                        .foregroundColor(.green)
                }
            }

            if !savedMessage.isEmpty {
                Section {
                    Text(savedMessage)
                        .foregroundColor(.green)
                }
            }

            if !generatedSummary.isEmpty {
                Section("Generated Report") {
                    Text(generatedSummary)
                        .textSelection(.enabled)
                        .font(.body)
                }
            }
        }
        .navigationTitle("SFST")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    notesFieldFocused = false
                }
            }
        }
    }

    private func buildSummary() -> String {
        let subjectText = subjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "the subject"
            : subjectName.trimmingCharacters(in: .whitespacesAndNewlines)

        let officerIdentity = officerLine()

        let header = """
        On \(formattedDate(incidentDate)), at approximately \(formattedTime(incidentTime)), \(officerIdentity) administered Standardized Field Sobriety Tests to \(subjectText) at \(valueOrPlaceholder(location)).
        """

        let conditions = """
        The tests were conducted under the following conditions: surface: \(valueOrPlaceholder(roadSurface)); lighting: \(valueOrPlaceholder(lighting)); weather: \(valueOrPlaceholder(weather)); footwear: \(valueOrPlaceholder(footwear)); medical or physical limitations noted: \(valueOrPlaceholder(medicalConditions)).
        """

        let hgnParagraph = """
        Horizontal Gaze Nystagmus (HGN) was explained and demonstrated as appropriate. A total of \(hgnCount) of 6 clues were observed. Observed clues: \(clueSentence(from: selectedHGNClues())).
        """

        let watParagraph = """
        Walk-and-Turn was explained and demonstrated as appropriate. A total of \(watCount) of 8 clues were observed. Observed clues: \(clueSentence(from: selectedWATClues())).
        """

        let olsParagraph = """
        One-Leg Stand was explained and demonstrated as appropriate. A total of \(olsCount) of 4 clues were observed. Observed clues: \(clueSentence(from: selectedOLSClues())).
        """

        let notesParagraph: String
        if officerNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notesParagraph = "No additional officer notes were entered."
        } else {
            notesParagraph = "Additional observations and notes: \(officerNotes.trimmingCharacters(in: .whitespacesAndNewlines))."
        }

        let conclusion = """
        Based on the subject's performance on the standardized field sobriety tests, the above observations were documented for report and evidentiary purposes.
        """

        return [
            header,
            conditions,
            hgnParagraph,
            watParagraph,
            olsParagraph,
            notesParagraph,
            conclusion
        ].joined(separator: "\n\n")
    }

    private func saveCurrentReport() {
        guard !generatedSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        let report = SavedSFSTReport(
            subjectName: trimmedName.isEmpty ? "Unnamed Subject" : trimmedName,
            reportText: generatedSummary
        )

        var existingReports = loadReports()
        existingReports.insert(report, at: 0)

        do {
            let data = try JSONEncoder().encode(existingReports)
            UserDefaults.standard.set(data, forKey: reportsStorageKey)
            savedMessage = "Report saved."
        } catch {
            savedMessage = "Could not save report."
        }
    }

    private func loadReports() -> [SavedSFSTReport] {
        guard let data = UserDefaults.standard.data(forKey: reportsStorageKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([SavedSFSTReport].self, from: data)
        } catch {
            return []
        }
    }

    private func officerLine() -> String {
        let trimmedOfficerName = officerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBadgeNumber = badgeNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAgencyName = agencyName.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedOfficerName.isEmpty && !trimmedBadgeNumber.isEmpty && !trimmedAgencyName.isEmpty {
            return "Officer \(trimmedOfficerName), badge \(trimmedBadgeNumber), of \(trimmedAgencyName)"
        } else if !trimmedOfficerName.isEmpty && !trimmedBadgeNumber.isEmpty {
            return "Officer \(trimmedOfficerName), badge \(trimmedBadgeNumber)"
        } else if !trimmedOfficerName.isEmpty {
            return "Officer \(trimmedOfficerName)"
        } else {
            return "the reporting officer"
        }
    }

    private func selectedHGNClues() -> [String] {
        var clues: [String] = []

        if hgnSmoothPursuitLeft { clues.append("lack of smooth pursuit in the left eye") }
        if hgnSmoothPursuitRight { clues.append("lack of smooth pursuit in the right eye") }
        if hgnMaxDeviationLeft { clues.append("distinct and sustained nystagmus at maximum deviation in the left eye") }
        if hgnMaxDeviationRight { clues.append("distinct and sustained nystagmus at maximum deviation in the right eye") }
        if hgnOnset45Left { clues.append("onset of nystagmus prior to 45 degrees in the left eye") }
        if hgnOnset45Right { clues.append("onset of nystagmus prior to 45 degrees in the right eye") }

        return clues
    }

    private func selectedWATClues() -> [String] {
        var clues: [String] = []

        if watCannotBalance { clues.append("could not keep balance during the instruction stage") }
        if watStartsTooSoon { clues.append("started too soon") }
        if watStopsWalking { clues.append("stopped while walking") }
        if watMissesHeelToToe { clues.append("missed heel-to-toe") }
        if watStepsOffLine { clues.append("stepped off line") }
        if watUsesArms { clues.append("used arms for balance") }
        if watImproperTurn { clues.append("made an improper turn") }
        if watWrongStepCount { clues.append("took an incorrect number of steps") }

        return clues
    }

    private func selectedOLSClues() -> [String] {
        var clues: [String] = []

        if olsSways { clues.append("swayed while balancing") }
        if olsUsesArms { clues.append("used arms for balance") }
        if olsHops { clues.append("hopped") }
        if olsFootDown { clues.append("put foot down") }

        return clues
    }

    private func clueSentence(from clues: [String]) -> String {
        if clues.isEmpty {
            return "no standardized clues were marked"
        } else {
            return clues.joined(separator: ", ")
        }
    }

    private func valueOrPlaceholder(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "not entered" : trimmed
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func resetForm() {
        subjectName = ""
        incidentDate = Date()
        incidentTime = Date()
        location = ""
        roadSurface = ""
        lighting = ""
        weather = ""
        footwear = ""
        medicalConditions = ""
        officerNotes = ""

        hgnSmoothPursuitLeft = false
        hgnSmoothPursuitRight = false
        hgnMaxDeviationLeft = false
        hgnMaxDeviationRight = false
        hgnOnset45Left = false
        hgnOnset45Right = false

        watCannotBalance = false
        watStartsTooSoon = false
        watStopsWalking = false
        watMissesHeelToToe = false
        watStepsOffLine = false
        watUsesArms = false
        watImproperTurn = false
        watWrongStepCount = false

        olsSways = false
        olsUsesArms = false
        olsHops = false
        olsFootDown = false

        generatedSummary = ""
        copiedMessage = ""
        savedMessage = ""
        notesFieldFocused = false
    }
}
