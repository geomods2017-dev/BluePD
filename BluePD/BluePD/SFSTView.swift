import SwiftUI
import UIKit

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
    @State private var showShareSheet = false
    @State private var generatedReport = ""

    @FocusState private var focusedField: ActiveField?

    private enum ActiveField: Hashable {
        case subjectName
        case location
        case medicalConditions
        case subjectStatements
        case officerNotes
    }

    private let roadOptions = ["Dry", "Wet", "Gravel", "Uneven", "Dirt", "Other"]
    private let lightingOptions = ["Daylight", "Dark - Lit", "Dark - Unlit", "Dawn / Dusk", "Other"]
    private let weatherOptions = ["Clear", "Rain", "Fog", "Snow", "Wind", "Other"]
    private let footwearOptions = ["Barefoot", "Sandals", "Boots", "Tennis Shoes", "Heels", "Other"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Button {
                    dismissKeyboard()
                    showImpliedConsent = true
                } label: {
                    rowCard(
                        title: "Indiana Implied Consent",
                        subtitle: "Open advisory card",
                        systemImage: "doc.text.fill"
                    )
                }
                .buttonStyle(.plain)

                sectionCard(title: "Subject & Incident", systemImage: "person.text.rectangle.fill") {
                    VStack(spacing: 12) {
                        StyledTextField(
                            title: "Subject Name",
                            text: $subjectName,
                            focusedField: $focusedField,
                            field: .subjectName
                        )

                        HStack(spacing: 12) {
                            StyledDateField(
                                title: "Date",
                                selection: $incidentDate,
                                displayedComponents: .date
                            )

                            StyledDateField(
                                title: "Time",
                                selection: $incidentTime,
                                displayedComponents: .hourAndMinute
                            )
                        }

                        StyledTextField(
                            title: "Location",
                            text: $location,
                            focusedField: $focusedField,
                            field: .location
                        )
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
                        StyledTextEditor(
                            title: "Medical Conditions",
                            text: $medicalConditions,
                            minHeight: 90,
                            focusedField: $focusedField,
                            field: .medicalConditions
                        )

                        StyledTextEditor(
                            title: "Subject Statements",
                            text: $subjectStatements,
                            minHeight: 110,
                            focusedField: $focusedField,
                            field: .subjectStatements
                        )
                    }
                }

                sectionCard(title: "HGN", systemImage: "eye.fill") {
                    VStack(spacing: 12) {
                        InstructionCard(
                            title: "HGN Instructions / Tips",
                            lines: [
                                "Check for equal pupil size before beginning.",
                                "Check for equal tracking.",
                                "Check for resting nystagmus.",
                                "Hold the stimulus about 12–15 inches from the subject’s face and slightly above eye level.",
                                "Instruct the subject to keep their head still and follow the stimulus with their eyes only.",
                                "Check lack of smooth pursuit in each eye.",
                                "Check distinct and sustained nystagmus at maximum deviation.",
                                "Check onset of nystagmus prior to 45 degrees.",
                                "Document any medical issues, head injury, or eye conditions."
                            ]
                        )

                        ToggleRow(title: "Resting Nystagmus", isOn: $hgnRestingNystagmusObserved)
                        ToggleRow(title: "Equal Tracking", isOn: $hgnEqualTrackingConfirmed)
                        ToggleRow(title: "Equal Pupil Size", isOn: $hgnEqualPupilSizeConfirmed)

                        Picker("Eye", selection: $selectedEye) {
                            Text("Left").tag("Left")
                            Text("Right").tag("Right")
                        }
                        .pickerStyle(.segmented)

                        if selectedEye == "Left" {
                            ToggleRow(title: "Lack of Smooth Pursuit", isOn: $hgnLeftLackOfSmoothPursuit)
                            ToggleRow(title: "Distinct Nystagmus", isOn: $hgnLeftDistinctNystagmus)
                            ToggleRow(title: "Onset < 45°", isOn: $hgnLeftOnsetPriorTo45)
                        } else {
                            ToggleRow(title: "Lack of Smooth Pursuit", isOn: $hgnRightLackOfSmoothPursuit)
                            ToggleRow(title: "Distinct Nystagmus", isOn: $hgnRightDistinctNystagmus)
                            ToggleRow(title: "Onset < 45°", isOn: $hgnRightOnsetPriorTo45)
                        }

                        SummaryCard(title: "HGN Clues", value: "\(totalHGNClues)/6")
                    }
                }

                sectionCard(title: "Walk & Turn", systemImage: "figure.walk") {
                    VStack(spacing: 10) {
                        InstructionCard(
                            title: "Walk-and-Turn Instructions",
                            lines: [
                                "Place your left foot on the line and your right foot ahead of it, heel-to-toe.",
                                "Keep your arms at your sides.",
                                "Do not start until told to begin.",
                                "Take 9 heel-to-toe steps.",
                                "Turn using a series of small steps.",
                                "Return with 9 heel-to-toe steps.",
                                "Count your steps out loud."
                            ]
                        )

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
                        InstructionCard(
                            title: "One-Leg Stand Instructions",
                            lines: [
                                "Stand with your feet together and arms at your sides.",
                                "Do not begin until told to begin.",
                                "Raise one foot about six inches off the ground.",
                                "Keep the raised foot parallel with the ground.",
                                "Keep both legs straight.",
                                "Look at the raised foot and count out loud until told to stop."
                            ]
                        )

                        ToggleRow(title: "Sways", isOn: $olsSways)
                        ToggleRow(title: "Uses Arms", isOn: $olsUsesArms)
                        ToggleRow(title: "Hops", isOn: $olsHops)
                        ToggleRow(title: "Foot Down", isOn: $olsPutsFootDown)

                        SummaryCard(title: "OLS Clues", value: "\(totalOLSClues)/4")
                    }
                }

                sectionCard(title: "Officer Notes", systemImage: "note.text") {
                    StyledTextEditor(
                        title: "Notes",
                        text: $officerNotes,
                        minHeight: 130,
                        focusedField: $focusedField,
                        field: .officerNotes
                    )
                }

                Button(action: generateReport) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Generate Report")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 3/255, green: 8/255, blue: 18/255),
                    Color(red: 7/255, green: 16/255, blue: 30/255),
                    Color(red: 12/255, green: 24/255, blue: 42/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture {
                dismissKeyboard()
            }
        )
        .navigationTitle("SFST Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
            }
        }
        .sheet(isPresented: $showImpliedConsent) {
            IndianaImpliedConsentView()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [generatedReport])
        }
    }

    private func generateReport() {
        dismissKeyboard()

        generatedReport = """
        SFST REPORT

        Subject: \(subjectName)
        Date: \(incidentDate.formatted(date: .abbreviated, time: .omitted))
        Time: \(incidentTime.formatted(date: .omitted, time: .shortened))
        Location: \(location)

        SCENE CONDITIONS
        Road Surface: \(roadSurface)
        Lighting: \(lighting)
        Weather: \(weather)
        Footwear: \(footwear)

        HGN PRE-TEST
        Resting Nystagmus: \(yesNo(hgnRestingNystagmusObserved))
        Equal Tracking: \(yesNo(hgnEqualTrackingConfirmed))
        Equal Pupil Size: \(yesNo(hgnEqualPupilSizeConfirmed))

        HGN CLUES
        Left - Lack of Smooth Pursuit: \(yesNo(hgnLeftLackOfSmoothPursuit))
        Left - Distinct Nystagmus: \(yesNo(hgnLeftDistinctNystagmus))
        Left - Onset < 45°: \(yesNo(hgnLeftOnsetPriorTo45))
        Right - Lack of Smooth Pursuit: \(yesNo(hgnRightLackOfSmoothPursuit))
        Right - Distinct Nystagmus: \(yesNo(hgnRightDistinctNystagmus))
        Right - Onset < 45°: \(yesNo(hgnRightOnsetPriorTo45))
        Total HGN Clues: \(totalHGNClues)/6

        WALK AND TURN
        Cannot Balance: \(yesNo(watCannotBalance))
        Starts Too Soon: \(yesNo(watStartsTooSoon))
        Stops Walking: \(yesNo(watStopsWalking))
        Misses Heel-To-Toe: \(yesNo(watMissesHeelToe))
        Steps Off Line: \(yesNo(watStepsOffLine))
        Uses Arms: \(yesNo(watUsesArms))
        Improper Turn: \(yesNo(watImproperTurn))
        Wrong Number of Steps: \(yesNo(watWrongNumberOfSteps))
        Total WAT Clues: \(totalWATClues)/8

        ONE LEG STAND
        Sways: \(yesNo(olsSways))
        Uses Arms: \(yesNo(olsUsesArms))
        Hops: \(yesNo(olsHops))
        Foot Down: \(yesNo(olsPutsFootDown))
        Total OLS Clues: \(totalOLSClues)/4

        Medical Conditions:
        \(medicalConditions)

        Subject Statements:
        \(subjectStatements)

        Officer Notes:
        \(officerNotes)
        """

        showShareSheet = true
    }

    private func yesNo(_ value: Bool) -> String {
        value ? "Yes" : "No"
    }

    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var totalHGNClues: Int {
        [
            hgnLeftLackOfSmoothPursuit,
            hgnLeftDistinctNystagmus,
            hgnLeftOnsetPriorTo45,
            hgnRightLackOfSmoothPursuit,
            hgnRightDistinctNystagmus,
            hgnRightOnsetPriorTo45
        ].filter { $0 }.count
    }

    private var totalWATClues: Int {
        [
            watCannotBalance,
            watStartsTooSoon,
            watStopsWalking,
            watMissesHeelToe,
            watStepsOffLine,
            watUsesArms,
            watImproperTurn,
            watWrongNumberOfSteps
        ].filter { $0 }.count
    }

    private var totalOLSClues: Int {
        [
            olsSways,
            olsUsesArms,
            olsHops,
            olsPutsFootDown
        ].filter { $0 }.count
    }

    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .foregroundColor(.white)
                .font(.headline)

            content()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    private func rowCard(title: String, subtitle: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)

                Text(subtitle)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct StyledTextField: View {
    let title: String
    @Binding var text: String
    var focusedField: FocusState<SFSTView.ActiveField?>.Binding
    let field: SFSTView.ActiveField

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            TextField(title, text: $text)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .foregroundColor(.white)
                .focused(focusedField, equals: field)
                .submitLabel(.done)
        }
    }
}

struct StyledDateField: View {
    let title: String
    @Binding var selection: Date
    let displayedComponents: DatePickerComponents

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            DatePicker(
                "",
                selection: $selection,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            .colorScheme(.dark)
        }
    }
}

struct DropdownField: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection)
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
        }
        .tint(.blue)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct StyledTextEditor: View {
    let title: String
    @Binding var text: String
    let minHeight: CGFloat
    var focusedField: FocusState<SFSTView.ActiveField?>.Binding
    let field: SFSTView.ActiveField

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .padding(8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .focused(focusedField, equals: field)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .foregroundColor(.white)
                .bold()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct InstructionCard: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.blue)

                    Text(line)
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct IndianaImpliedConsentView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Indiana Implied Consent")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("""
Indiana law requires submission to a certified chemical test when an officer has probable cause to believe a person operated a vehicle while intoxicated.

Refusal may result in license suspension and other legal consequences.

Verify agency-approved wording before field use.
""")
                    .foregroundColor(.white)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 3/255, green: 8/255, blue: 18/255),
                        Color(red: 7/255, green: 16/255, blue: 30/255),
                        Color(red: 12/255, green: 24/255, blue: 42/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Implied Consent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
