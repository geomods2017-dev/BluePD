import SwiftUI

struct SFSTView: View {
    @State private var subjectName = ""
    @State private var incidentDate = Date()
    @State private var incidentTime = Date()
    @State private var location = ""

    @State private var roadSurface = "Dry"
    @State private var lighting = "Daylight"
    @State private var weather = "Clear"
    @State private var footwear = "Tennis Shoes"

    @State private var medicalConditions = ""
    @State private var subjectStatements = ""
    @State private var officerNotes = ""

    @State private var hgnRestingNystagmusObserved = false
    @State private var hgnEqualTrackingConfirmed = false
    @State private var hgnEqualPupilSizeConfirmed = false

    @State private var selectedEye = "Left"

    @State private var hgnLeftLackOfSmoothPursuit = false
    @State private var hgnLeftDistinctNystagmus = false
    @State private var hgnLeftOnsetPriorTo45 = false

    @State private var hgnRightLackOfSmoothPursuit = false
    @State private var hgnRightDistinctNystagmus = false
    @State private var hgnRightOnsetPriorTo45 = false

    @State private var watCannotBalance = false
    @State private var watStartsTooSoon = false
    @State private var watStopsWalking = false
    @State private var watMissesHeelToe = false
    @State private var watStepsOffLine = false
    @State private var watUsesArms = false
    @State private var watImproperTurn = false
    @State private var watWrongNumberOfSteps = false

    @State private var olsSways = false
    @State private var olsUsesArms = false
    @State private var olsHops = false
    @State private var olsPutsFootDown = false

    @State private var showImpliedConsent = false

    private let roadOptions = ["Dry", "Wet", "Gravel", "Uneven", "Dirt", "Other"]
    private let lightingOptions = ["Daylight", "Dark - Lit", "Dark - Unlit", "Dawn / Dusk", "Other"]
    private let weatherOptions = ["Clear", "Rain", "Fog", "Snow", "Wind", "Other"]
    private let footwearOptions = ["Barefoot", "Sandals", "Boots", "Tennis Shoes", "Heels", "Other"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Button {
                    showImpliedConsent = true
                } label: {
                    rowCard(title: "Indiana Implied Consent", subtitle: "Open advisory card", systemImage: "doc.text.fill")
                }

                sectionCard(title: "Subject & Incident", systemImage: "person.text.rectangle.fill") {
                    VStack(spacing: 12) {
                        StyledTextField(title: "Subject Name", text: $subjectName)

                        HStack {
                            StyledDateField(title: "Date", selection: $incidentDate, displayedComponents: .date)
                            StyledDateField(title: "Time", selection: $incidentTime, displayedComponents: .hourAndMinute)
                        }

                        StyledTextField(title: "Location", text: $location)
                    }
                }

                sectionCard(title: "Scene Conditions", systemImage: "car.fill") {
                    VStack(spacing: 12) {
                        DropdownField(title: "Road Surface", selection: $roadSurface, options: roadOptions)
                        DropdownField(title: "Lighting", selection: $lighting, options: lightingOptions)
                        DropdownField(title: "Weather", selection: $weather, options: weatherOptions)
                        DropdownField(title: "Footwear", selection: $footwear, options: footwearOptions)
                    }
                }

                sectionCard(title: "Medical & Statements", systemImage: "cross.case.fill") {
                    VStack(spacing: 12) {
                        StyledTextEditor(title: "Medical Conditions", text: $medicalConditions, minHeight: 90)
                        StyledTextEditor(title: "Subject Statements", text: $subjectStatements, minHeight: 110)
                    }
                }

                sectionCard(title: "HGN", systemImage: "eye.fill") {
                    VStack(spacing: 12) {

                        ToggleRow(title: "Resting Nystagmus", isOn: $hgnRestingNystagmusObserved)
                        ToggleRow(title: "Equal Tracking", isOn: $hgnEqualTrackingConfirmed)
                        ToggleRow(title: "Equal Pupil Size", isOn: $hgnEqualPupilSizeConfirmed)

                        Picker("Eye", selection: $selectedEye) {
                            Text("Left").tag("Left")
                            Text("Right").tag("Right")
                        }
                        .pickerStyle(.segmented)

                        if selectedEye == "Left" {
                            ToggleRow(title: "Smooth Pursuit", isOn: $hgnLeftLackOfSmoothPursuit)
                            ToggleRow(title: "Distinct Nystagmus", isOn: $hgnLeftDistinctNystagmus)
                            ToggleRow(title: "Onset < 45°", isOn: $hgnLeftOnsetPriorTo45)
                        } else {
                            ToggleRow(title: "Smooth Pursuit", isOn: $hgnRightLackOfSmoothPursuit)
                            ToggleRow(title: "Distinct Nystagmus", isOn: $hgnRightDistinctNystagmus)
                            ToggleRow(title: "Onset < 45°", isOn: $hgnRightOnsetPriorTo45)
                        }

                        SummaryCard(title: "HGN Clues", value: "\(totalHGNClues)/6")
                    }
                }

                sectionCard(title: "Walk & Turn", systemImage: "figure.walk") {
                    VStack(spacing: 10) {
                        ToggleRow(title: "Cannot Balance", isOn: $watCannotBalance)
                        ToggleRow(title: "Starts Too Soon", isOn: $watStartsTooSoon)
                        ToggleRow(title: "Stops Walking", isOn: $watStopsWalking)
                        ToggleRow(title: "Misses Heel-To-Toe", isOn: $watMissesHeelToe)
                        ToggleRow(title: "Steps Off Line", isOn: $watStepsOffLine)
                        ToggleRow(title: "Uses Arms", isOn: $watUsesArms)
                        ToggleRow(title: "Improper Turn", isOn: $watImproperTurn)
                        ToggleRow(title: "Wrong Steps", isOn: $watWrongNumberOfSteps)

                        SummaryCard(title: "WAT Clues", value: "\(totalWATClues)/8")
                    }
                }

                sectionCard(title: "One Leg Stand", systemImage: "figure.stand") {
                    VStack(spacing: 10) {
                        ToggleRow(title: "Sways", isOn: $olsSways)
                        ToggleRow(title: "Uses Arms", isOn: $olsUsesArms)
                        ToggleRow(title: "Hops", isOn: $olsHops)
                        ToggleRow(title: "Foot Down", isOn: $olsPutsFootDown)

                        SummaryCard(title: "OLS Clues", value: "\(totalOLSClues)/4")
                    }
                }

                sectionCard(title: "Officer Notes", systemImage: "note.text") {
                    StyledTextEditor(title: "Notes", text: $officerNotes, minHeight: 130)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showImpliedConsent) {
            IndianaImpliedConsentView()
        }
    }

    private var totalHGNClues: Int {
        [hgnLeftLackOfSmoothPursuit, hgnLeftDistinctNystagmus, hgnLeftOnsetPriorTo45,
         hgnRightLackOfSmoothPursuit, hgnRightDistinctNystagmus, hgnRightOnsetPriorTo45].filter { $0 }.count
    }

    private var totalWATClues: Int {
        [watCannotBalance, watStartsTooSoon, watStopsWalking, watMissesHeelToe,
         watStepsOffLine, watUsesArms, watImproperTurn, watWrongNumberOfSteps].filter { $0 }.count
    }

    private var totalOLSClues: Int {
        [olsSways, olsUsesArms, olsHops, olsPutsFootDown].filter { $0 }.count
    }

    private func sectionCard<Content: View>(title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: systemImage).foregroundColor(.white)
            content()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    private func rowCard(title: String, subtitle: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle).font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

/* ---------- FIXED MISSING COMPONENTS ---------- */

struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).bold()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct IndianaImpliedConsentView: View {
    var body: some View {
        ScrollView {
            Text("Indiana Implied Consent Advisory...")
                .padding()
        }
    }
}
