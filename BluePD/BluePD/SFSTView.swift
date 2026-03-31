import SwiftUI
import UIKit

struct SFSTView: View {
    @AppStorage("officerName") private var officerName: String = ""
    @AppStorage("badgeNumber") private var badgeNumber: String = ""
    @AppStorage("agencyName") private var agencyName: String = ""
    @AppStorage("officerRank") private var officerRank: String = ""
    @AppStorage("officerUnit") private var officerUnit: String = ""
    @AppStorage("autoFillOfficerInfo") private var autoFillOfficerInfo: Bool = true

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

    @State private var hgnExpanded = true
    @State private var watExpanded = true
    @State private var olsExpanded = true

    @State private var hgnRestingNystagmusObserved = false
    @State private var hgnEqualTrackingConfirmed = false
    @State private var hgnEqualPupilSizeConfirmed = false

    @State private var hgnHeadInjuryQuestion = ""
    @State private var hgnEyeConditionQuestion = ""
    @State private var hgnVisionCorrectionQuestion = ""
    @State private var hgnMedicationQuestion = ""

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
        case hgnHeadInjuryQuestion
        case hgnEyeConditionQuestion
        case hgnVisionCorrectionQuestion
        case hgnMedicationQuestion
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
            Section {
                headerCard
            }

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

            Section {
                DisclosureGroup(isExpanded: $hgnExpanded) {
                    VStack(spacing: 12) {
                        SFSTInfoCard(
                            title: "Officer Setup",
                            icon: "eye",
                            rows: [
                                "Confirm the subject understands instructions.",
                                "Remove distractions when practical.",
                                "Position the stimulus approximately 12–15 inches from the subject’s face.",
                                "Hold the stimulus slightly above eye level.",
                                "Tell the subject to keep the head still and follow the stimulus with the eyes only."
                            ]
                        )

                        SFSTTimingCard(
                            title: "Lack of Smooth Pursuit",
                            time: "2",
                            detail: "Move from center to side in about 2 seconds, then return in about 2 seconds."
                        )

                        SFSTTimingCard(
                            title: "Maximum Deviation",
                            time: "4",
                            detail: "Move to maximum deviation and hold for at least 4 seconds."
                        )

                        SFSTTimingCard(
                            title: "Onset Prior to 45°",
                            time: "4",
                            detail: "Move slowly from center to side in about 4 seconds."
                        )

                        SFSTInfoCard(
                            title: "Officer Reminders",
                            icon: "checkmark.shield",
                            rows: [
                                "Keep stimulus speed consistent.",
                                "Hold maximum deviation at least 4 seconds.",
                                "Check both eyes equally.",
                                "Note any medical, eye, or head injury concerns.",
                                "Document unusual responses or inability to complete."
                            ]
                        )

                        Toggle("Equal Tracking Confirmed", isOn: $hgnEqualTrackingConfirmed)
                        Toggle("Equal Pupil Size Confirmed", isOn: $hgnEqualPupilSizeConfirmed)
                        Toggle("Resting Nystagmus Observed", isOn: $hgnRestingNystagmusObserved)

                        TextField("Head injury / recent trauma?", text: $hgnHeadInjuryQuestion)
                            .focused($activeField, equals: .hgnHeadInjuryQuestion)

                        TextField("Eye conditions / vision problems?", text: $hgnEyeConditionQuestion)
                            .focused($activeField, equals: .hgnEyeConditionQuestion)

                        TextField("Contacts or glasses?", text: $hgnVisionCorrectionQuestion)
                            .focused($activeField, equals: .hgnVisionCorrectionQuestion)

                        TextField("Medications affecting eyes / balance?", text: $hgnMedicationQuestion)
                            .focused($activeField, equals: .hgnMedicationQuestion)

                        Toggle("Lack of Smooth Pursuit — Left Eye", isOn: $hgnSmoothPursuitLeft)
                        Toggle("Lack of Smooth Pursuit — Right Eye", isOn: $hgnSmoothPursuitRight)
                        Toggle("Distinct and Sustained Nystagmus at Maximum Deviation — Left Eye", isOn: $hgnMaxDeviationLeft)
                        Toggle("Distinct and Sustained Nystagmus at Maximum Deviation — Right Eye", isOn: $hgnMaxDeviationRight)
                        Toggle("Onset of Nystagmus Prior to 45 Degrees — Left Eye", isOn: $hgnOnset45Left)
                        Toggle("Onset of Nystagmus Prior to 45 Degrees — Right Eye", isOn: $hgnOnset45Right)
                    }
                    .padding(.top, 8)
                } label: {
                    sectionHeader(
                        title: "HGN",
                        subtitle: "\(hgnCount) / 6 clues",
                        systemImage: "eye.fill"
                    )
                }
            }

            Section {
                DisclosureGroup(isExpanded: $watExpanded) {
                    VStack(alignment: .leading, spacing: 12) {
                        SFSTInfoCard(
                            title: "Walk-and-Turn Instructions",
                            icon: "figure.walk",
                            rows: [
                                "Place the left foot on the line.",
                                "Place the right foot in front of the left foot, heel-to-toe.",
                                "Keep arms at sides while instructions are given.",
                                "Do not begin until told to start.",
                                "Take 9 heel-to-toe steps, turn using a series of small steps, and take 9 heel-to-toe steps back.",
                                "Count steps out loud and watch the feet."
                            ]
                        )

                        Toggle("Cannot Keep Balance During Instructions", isOn: $watCannotBalance)
                        Toggle("Starts Too Soon", isOn: $watStartsTooSoon)
                        Toggle("Stops While Walking", isOn: $watStopsWalking)
                        Toggle("Misses Heel-to-Toe", isOn: $watMissesHeelToToe)
                        Toggle("Steps Off Line", isOn: $watStepsOffLine)
                        Toggle("Uses Arms for Balance", isOn: $watUsesArms)
                        Toggle("Improper Turn", isOn: $watImproperTurn)
                        Toggle("Incorrect Number of Steps", isOn: $watWrongStepCount)
                    }
                    .padding(.top, 8)
                } label: {
                    sectionHeader(
                        title: "Walk-and-Turn",
                        subtitle: "\(watCount) / 8 clues",
                        systemImage: "figure.walk.motion"
                    )
                }
            }

            Section {
                DisclosureGroup(isExpanded: $olsExpanded) {
                    VStack(alignment: .leading, spacing: 12) {
                        SFSTInfoCard(
                            title: "One-Leg Stand Instructions",
                            icon: "figure.stand",
                            rows: [
                                "Stand with feet together and arms at sides.",
                                "Raise one foot approximately 6 inches off the ground.",
                                "Keep the raised foot parallel to the ground.",
                                "Look at the raised foot and count out loud as instructed.",
                                "Continue until told to stop."
                            ]
                        )

                        Toggle("Sways While Balancing", isOn: $olsSways)
                        Toggle("Uses Arms for Balance", isOn: $olsUsesArms)
                        Toggle("Hops", isOn: $olsHops)
                        Toggle("Puts Foot Down", isOn: $olsFootDown)
                    }
                    .padding(.top, 8)
                } label: {
                    sectionHeader(
                        title: "One-Leg Stand",
                        subtitle: "\(olsCount) / 4 clues",
                        systemImage: "figure.stand.line.dotted.figure.stand"
                    )
                }
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

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(.blue)
                Text("SFST Field Worksheet")
                    .font(.headline)
            }

            Text("Roadside reference, clue tracking, and quick summary generation.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if autoFillOfficerInfo && hasOfficerInfo {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Officer Info Auto-Fill Enabled")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(compactOfficerLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func sectionHeader(title: String, subtitle: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.headline)

            Spacer()

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var hasOfficerInfo: Bool {
        !officerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !badgeNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !agencyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !officerRank.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !officerUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var compactOfficerLine: String {
        [
            officerRank.trimmingCharacters(in: .whitespacesAndNewlines),
            officerName.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " ")
        + (badgeNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : " • Badge \(badgeNumber.trimmingCharacters(in: .whitespacesAndNewlines))")
        + (agencyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : " • \(agencyName.trimmingCharacters(in: .whitespacesAndNewlines))")
        + (officerUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : " • \(officerUnit.trimmingCharacters(in: .whitespacesAndNewlines))")
    }

    private func buildSummary() -> String {
        let subjectText = subjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Not entered"
            : subjectName.trimmingCharacters(in: .whitespacesAndNewlines)

        let officerBlock: String = {
            guard autoFillOfficerInfo && hasOfficerInfo else { return "" }

            return """
Officer Information:
Officer: \(valueOrPlaceholder(officerName))
Rank / Title: \(valueOrPlaceholder(officerRank))
Badge Number: \(valueOrPlaceholder(badgeNumber))
Agency: \(valueOrPlaceholder(agencyName))
Unit: \(valueOrPlaceholder(officerUnit))
"""
        }()

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

        let hgnPretestBlock = """
HGN Pre-Test:
Equal Tracking Confirmed: \(yesNo(hgnEqualTrackingConfirmed))
Equal Pupil Size Confirmed: \(yesNo(hgnEqualPupilSizeConfirmed))
Resting Nystagmus Observed: \(yesNo(hgnRestingNystagmusObserved))
Head Injury / Recent Trauma: \(valueOrPlaceholder(hgnHeadInjuryQuestion))
Eye Conditions / Vision Problems: \(valueOrPlaceholder(hgnEyeConditionQuestion))
Contacts or Glasses: \(valueOrPlaceholder(hgnVisionCorrectionQuestion))
Medications Affecting Eyes / Balance: \(valueOrPlaceholder(hgnMedicationQuestion))
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
            officerBlock,
            infoBlock,
            hgnPretestBlock,
            hgnBlock,
            watBlock,
            olsBlock,
            subjectStatementBlock,
            notesBlock
        ]
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .joined(separator: "\n\n")
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

    private func yesNo(_ value: Bool) -> String {
        value ? "Yes" : "No"
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

        hgnExpanded = true
        watExpanded = true
        olsExpanded = true

        hgnRestingNystagmusObserved = false
        hgnEqualTrackingConfirmed = false
        hgnEqualPupilSizeConfirmed = false

        hgnHeadInjuryQuestion = ""
        hgnEyeConditionQuestion = ""
        hgnVisionCorrectionQuestion = ""
        hgnMedicationQuestion = ""

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

private struct SFSTInfoCard: View {
    let title: String
    let icon: String
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(rows, id: \.self) { row in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 7))
                            .padding(.top, 6)
                            .foregroundStyle(.blue)

                        Text(row)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.blue.opacity(0.16), lineWidth: 1)
        )
        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        .listRowBackground(Color.clear)
    }
}

private struct SFSTTimingCard: View {
    let title: String
    let time: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Text(time)
                    .font(.headline)
                    .fontWeight(.bold)

                Text("SEC")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 58, height: 58)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.orange.opacity(0.16))
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.orange.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.orange.opacity(0.16), lineWidth: 1)
        )
        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        .listRowBackground(Color.clear)
    }
}
