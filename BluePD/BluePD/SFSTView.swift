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
                Button("Reset SFST Form", role: .destructive) {
                    resetForm()
                }
            }
        }
        .navigationTitle("SFST")
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
    }
}
