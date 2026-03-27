import SwiftUI

struct SFSTView: View {
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

    @State private var officerNotes = ""
    @State private var generatedSummary = ""

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
            Section("HGN — Total Clues: \(hgnCount)/6") {
                Toggle("Lack of Smooth Pursuit — Left Eye", isOn: $hgnSmoothPursuitLeft)
                Toggle("Lack of Smooth Pursuit — Right Eye", isOn: $hgnSmoothPursuitRight)
                Toggle("Distinct and Sustained Nystagmus at Max Deviation — Left Eye", isOn: $hgnMaxDeviationLeft)
                Toggle("Distinct and Sustained Nystagmus at Max Deviation — Right Eye", isOn: $hgnMaxDeviationRight)
                Toggle("Onset Prior to 45 Degrees — Left Eye", isOn: $hgnOnset45Left)
                Toggle("Onset Prior to 45 Degrees — Right Eye", isOn: $hgnOnset45Right)
            }

            Section("Walk-and-Turn — Total Clues: \(watCount)/8") {
                Toggle("Cannot Keep Balance During Instructions", isOn: $watCannotBalance)
                Toggle("Starts Too Soon", isOn: $watStartsTooSoon)
                Toggle("Stops While Walking", isOn: $watStopsWalking)
                Toggle("Misses Heel-to-Toe", isOn: $watMissesHeelToToe)
                Toggle("Steps Off Line", isOn: $watStepsOffLine)
                Toggle("Uses Arms for Balance", isOn: $watUsesArms)
                Toggle("Improper Turn", isOn: $watImproperTurn)
                Toggle("Incorrect Number of Steps", isOn: $watWrongStepCount)
            }

            Section("One-Leg Stand — Total Clues: \(olsCount)/4") {
                Toggle("Sways While Balancing", isOn: $olsSways)
                Toggle("Uses Arms for Balance", isOn: $olsUsesArms)
                Toggle("Hops", isOn: $olsHops)
                Toggle("Puts Foot Down", isOn: $olsFootDown)
            }

            Section("Officer Notes") {
                TextEditor(text: $officerNotes)
                    .frame(minHeight: 120)
            }

            Section("Quick Summary") {
                Text("HGN: \(hgnCount) clue(s)")
                Text("Walk-and-Turn: \(watCount) clue(s)")
                Text("One-Leg Stand: \(olsCount) clue(s)")
            }

            Section {
                Button("Generate Report Summary") {
                    generatedSummary = buildSummary()
                }

                Button("Reset SFST Form", role: .destructive) {
                    resetForm()
                }
            }

            if !generatedSummary.isEmpty {
                Section("Generated Narrative") {
                    Text(generatedSummary)
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle("SFST")
    }

    private func buildSummary() -> String {
        let hgnClues = selectedHGNClues()
        let watClues = selectedWATClues()
        let olsClues = selectedOLSClues()

        var summary = "Standardized Field Sobriety Tests were administered and the following clues were observed. "

        summary += "On HGN, \(hgnCount) of 6 clues were observed"
        if !hgnClues.isEmpty {
            summary += ": " + hgnClues.joined(separator: ", ")
        }
        summary += ". "

        summary += "On Walk-and-Turn, \(watCount) of 8 clues were observed"
        if !watClues.isEmpty {
            summary += ": " + watClues.joined(separator: ", ")
        }
        summary += ". "

        summary += "On One-Leg Stand, \(olsCount) of 4 clues were observed"
        if !olsClues.isEmpty {
            summary += ": " + olsClues.joined(separator: ", ")
        }
        summary += "."

        if !officerNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            summary += " Additional notes: \(officerNotes.trimmingCharacters(in: .whitespacesAndNewlines))."
        }

        return summary
    }

    private func selectedHGNClues() -> [String] {
        var clues: [String] = []

        if hgnSmoothPursuitLeft { clues.append("lack of smooth pursuit in left eye") }
        if hgnSmoothPursuitRight { clues.append("lack of smooth pursuit in right eye") }
        if hgnMaxDeviationLeft { clues.append("distinct and sustained nystagmus at maximum deviation in left eye") }
        if hgnMaxDeviationRight { clues.append("distinct and sustained nystagmus at maximum deviation in right eye") }
        if hgnOnset45Left { clues.append("onset of nystagmus prior to 45 degrees in left eye") }
        if hgnOnset45Right { clues.append("onset of nystagmus prior to 45 degrees in right eye") }

        return clues
    }

    private func selectedWATClues() -> [String] {
        var clues: [String] = []

        if watCannotBalance { clues.append("could not keep balance during instructions") }
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

    private func resetForm() {
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

        officerNotes = ""
        generatedSummary = ""
    }
}
