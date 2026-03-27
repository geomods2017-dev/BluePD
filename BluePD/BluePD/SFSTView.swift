import SwiftUI
import UIKit

struct SFSTView: View {
    @State private var subjectName = ""
    @State private var incidentDate = Date()
    @State private var incidentTime = Date()
    @State private var location = ""
    @State private var roadSurface = ""
    @State private var lighting = ""
    @State private var weather = ""
    @State private var footwear = ""
    @State private var medicalConditions = ""
    @State private var subjectStatements = ""
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
    @State private var showingResetConfirmation = false

    @FocusState private var activeField: ActiveField?

    private let reportsStorageKey = "saved_sfst_reports"

    enum ActiveField: Hashable {
        case subjectStatements
        case officerNotes
    }

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
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
            }

            Section("One-Leg Stand Clues — Total: \(olsCount)/4") {
                Toggle("Sways While Balancing", isOn: $olsSways)
                Toggle("Uses Arms for Balance", isOn: $olsUsesArms)
                Toggle("Hops", isOn: $olsHops)
                Toggle("Puts Foot Down", isOn: $olsFootDown)
            }

            Section("Subject Statements") {
                TextEditor(text: $subjectStatements)
                    .frame(minHeight: 100)
                    .focused($activeField, equals: .subjectStatements)
            }

            Section("Officer Notes") {
                TextEditor(text: $officerNotes)
                    .frame(minHeight: 140)
                    .focused($activeField, equals: .officerNotes)
            }

            Section("Quick Totals") {
                Text("HGN: \(hgnCount) / 6")
                Text("Walk-and-Turn: \(watCount) / 8")
                Text("One-Leg Stand: \(olsCount) / 4")
            }

            Section("Actions") {
                Button("Generate Field Notes Summary") {
                    activeField = nil
                    generatedSummary = buildSummary()
                    copiedMessage = ""
                    savedMessage = ""
                }

                if !generatedSummary.isEmpty {
                    Button("Copy Summary") {
                        UIPasteboard.general.string = generatedSummary
                        copiedMessage = "Summary copied to clipboard."
                        savedMessage = ""
                        activeField = nil
                    }

                    Button("Save Summary") {
                        saveCurrentReport()
                        copiedMessage = ""
                        activeField = nil
                    }
                }

                Button("Dismiss Keyboard") {
                    activeField = nil
                }

                Button("Reset SFST Form", role: .destructive) {
                    showingResetConfirmation = true
                }
            }

            if !copiedMessage.isEmpty {
                Section {
                    Text(copiedMessage)
                        .foregroundStyle(.green)
                }
            }

            if !savedMessage.isEmpty {
                Section {
                    Text(savedMessage)
                        .foregroundStyle(.green)
                }
            }

            if !generatedSummary.isEmpty {
                Section("Generated Field Notes Summary") {
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
                    activeField = nil
                }
            }
        }
        .alert("Reset SFST Form?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetForm()
            }
        } message: {
            Text("This will clear all selected clues, notes, and summary text.")
        }
    }

    private func buildSummary() -> String {
        let subjectText = subjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Not entered"
            : subjectName.trimmingCharacters(in: .whitespacesAndNewlines)

        let infoBlock = """
Subject: \(subjectText)
Date: \(formattedDate(incidentDate))
Time: \(formattedTime(incidentTime))
Location: \(valueOrPlaceholder(location))
Surface: \(valueOrPlaceholder(roadSurface))
Lighting: \(valueOrPlaceholder(lighting))
Weather: \(valueOrPlaceholder(weather))
Footwear: \(valueOrPlaceholder(footwear))
Medical / Physical Limitations: \(valueOrPlaceholder(medicalConditions))
"""

        let hgnBlock = """
HGN (\(hgnCount)/6):
\(bulletList(from: selectedHGNClues()))
"""

        let watBlock = """
Walk-and-Turn (\(watCount)/8):
\(bulletList(from: selectedWATClues()))
"""

        let olsBlock = """
One-Leg Stand (\(olsCount)/4):
\(bulletList(from: selectedOLSClues()))
"""

        let subjectStatementBlock = """
Subject Statements:
\(multilineValueOrPlaceholder(subjectStatements))
"""

        let notesBlock = """
Officer Notes:
\(multilineValueOrPlaceholder(officerNotes))
"""

        return [
            infoBlock,
            hgnBlock,
            watBlock,
            olsBlock,
            subjectStatementBlock,
            notesBlock
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
            savedMessage = "Summary saved."
        } catch {
            savedMessage = "Could not save summary."
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

    private func selectedHGNClues() -> [String] {
        var clues: [String] = []

        if hgnSmoothPursuitLeft { clues.append("Lack of smooth pursuit — left eye") }
        if hgnSmoothPursuitRight { clues.append("Lack of smooth pursuit — right eye") }
        if hgnMaxDeviationLeft { clues.append("Distinct and sustained nystagmus at maximum deviation — left eye") }
        if hgnMaxDeviationRight { clues.append("Distinct and sustained nystagmus at maximum deviation — right eye") }
        if hgnOnset45Left { clues.append("Onset of nystagmus prior to 45 degrees — left eye") }
        if hgnOnset45Right { clues.append("Onset of nystagmus prior to 45 degrees — right eye") }

        return clues
    }

    private func selectedWATClues() -> [String] {
        var clues: [String] = []

        if watCannotBalance { clues.append("Cannot keep balance during instructions") }
        if watStartsTooSoon { clues.append("Starts too soon") }
        if watStopsWalking { clues.append("Stops while walking") }
        if watMissesHeelToToe { clues.append("Misses heel-to-toe") }
        if watStepsOffLine { clues.append("Steps off line") }
        if watUsesArms { clues.append("Uses arms for balance") }
        if watImproperTurn { clues.append("Improper turn") }
        if watWrongStepCount { clues.append("Incorrect number of steps") }

        return clues
    }

    private func selectedOLSClues() -> [String] {
        var clues: [String] = []

        if olsSways { clues.append("Sways while balancing") }
        if olsUsesArms { clues.append("Uses arms for balance") }
        if olsHops { clues.append("Hops") }
        if olsFootDown { clues.append("Puts foot down") }

        return clues
    }

    private func bulletList(from items: [String]) -> String {
        if items.isEmpty {
            return "• No clues selected"
        }
        return items.map { "• \($0)" }.joined(separator: "\n")
    }

    private func valueOrPlaceholder(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Not entered" : trimmed
    }

    private func multilineValueOrPlaceholder(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Not entered" : trimmed
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
        subjectStatements = ""
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
        activeField = nil
    }
}
