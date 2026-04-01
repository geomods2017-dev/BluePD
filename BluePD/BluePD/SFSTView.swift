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
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.16))
                                .frame(width: 42, height: 42)

                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Indiana Implied Consent")
                                .foregroundColor(.white)
                                .font(.headline)

                            Text("Open advisory card")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                }
                .buttonStyle(.plain)

                sectionCard(title: "Subject & Incident", systemImage: "person.text.rectangle.fill") {
                    VStack(spacing: 12) {
                        StyledTextField(title: "Subject Name", text: $subjectName)
                        HStack(spacing: 12) {
                            StyledDateField(
                                title: "Incident Date",
                                selection: $incidentDate,
                                displayedComponents: .date
                            )
                            StyledDateField(
                                title: "Incident Time",
                                selection: $incidentTime,
                                displayedComponents: .hourAndMinute
                            )
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

                sectionCard(title: "HGN Pre-Test", systemImage: "eye.fill") {
                    VStack(spacing: 10) {
                        ToggleRow(title: "Resting Nystagmus Observed", isOn: $hgnRestingNystagmusObserved, systemImage: "eye.trianglebadge.exclamationmark")
                        ToggleRow(title: "Equal Tracking Confirmed", isOn: $hgnEqualTrackingConfirmed, systemImage: "arrow.left.and.right")
                        ToggleRow(title: "Equal Pupil Size Confirmed", isOn: $hgnEqualPupilSizeConfirmed, systemImage: "circle.lefthalf.filled")
                    }
                }

                sectionCard(title: "HGN Clues", systemImage: "eye.circle.fill") {
                    VStack(spacing: 14) {
                        Picker("Eye", selection: $selectedEye) {
                            Text("Left Eye").tag("Left")
                            Text("Right Eye").tag("Right")
                        }
                        .pickerStyle(.segmented)

                        if selectedEye == "Left" {
                            VStack(spacing: 10) {
                                ToggleRow(title: "Lack of Smooth Pursuit", isOn: $hgnLeftLackOfSmoothPursuit, systemImage: "checkmark.shield.fill")
                                ToggleRow(title: "Distinct Nystagmus", isOn: $hgnLeftDistinctNystagmus, systemImage: "checkmark.shield.fill")
                                ToggleRow(title: "Onset Prior to 45°", isOn: $hgnLeftOnsetPriorTo45, systemImage: "checkmark.shield.fill")
                            }
                        } else {
                            VStack(spacing: 10) {
                                ToggleRow(title: "Lack of Smooth Pursuit", isOn: $hgnRightLackOfSmoothPursuit, systemImage: "checkmark.shield.fill")
                                ToggleRow(title: "Distinct Nystagmus", isOn: $hgnRightDistinctNystagmus, systemImage: "checkmark.shield.fill")
                                ToggleRow(title: "Onset Prior to 45°", isOn: $hgnRightOnsetPriorTo45, systemImage: "checkmark.shield.fill")
                            }
                        }

                        SummaryCard(title: "Total HGN Clues", value: "\(totalHGNClues) / 6", systemImage: "waveform.path.ecg")
                    }
                }

                sectionCard(title: "Walk and Turn", systemImage: "figure.walk") {
                    VStack(spacing: 14) {
                        InstructionCard(
                            title: "Instruction Card",
                            lines: [
                                "Place left foot on the line and right foot in front, heel-to-toe.",
                                "Keep your arms at your sides.",
                                "Do not start until told to begin.",
                                "Take 9 heel-to-toe steps.",
                                "Turn using a series of small steps.",
                                "Return with 9 heel-to-toe steps.",
                                "Count the steps out loud."
                            ]
                        )

                        VStack(spacing: 10) {
                            ToggleRow(title: "Cannot Balance", isOn: $watCannotBalance, systemImage: "figure.walk")
                            ToggleRow(title: "Starts Too Soon", isOn: $watStartsTooSoon, systemImage: "figure.walk")
                            ToggleRow(title: "Stops Walking", isOn: $watStopsWalking, systemImage: "figure.walk")
                            ToggleRow(title: "Misses Heel-To-Toe", isOn: $watMissesHeelToe, systemImage: "figure.walk")
                            ToggleRow(title: "Steps Off Line", isOn: $watStepsOffLine, systemImage: "figure.walk")
                            ToggleRow(title: "Uses Arms for Balance", isOn: $watUsesArms, systemImage: "figure.walk")
                            ToggleRow(title: "Improper Turn", isOn: $watImproperTurn, systemImage: "figure.walk")
                            ToggleRow(title: "Wrong Number of Steps", isOn: $watWrongNumberOfSteps, systemImage: "figure.walk")
                        }

                        SummaryCard(title: "Walk-and-Turn Clues", value: "\(totalWATClues) / 8", systemImage: "list.number")
                    }
                }

                sectionCard(title: "One Leg Stand", systemImage: "figure.stand") {
                    VStack(spacing: 14) {
                        InstructionCard(
                            title: "Instruction Card",
                            lines: [
                                "Stand with your feet together and arms at your sides.",
                                "Do not begin until told.",
                                "Raise one foot about six inches off the ground.",
                                "Keep the raised foot parallel to the ground.",
                                "Keep both legs straight and look at the raised foot.",
                                "Count out loud until told to stop."
                            ]
                        )

                        VStack(spacing: 10) {
                            ToggleRow(title: "Sways While Balancing", isOn: $olsSways, systemImage: "figure.stand")
                            ToggleRow(title: "Uses Arms for Balance", isOn: $olsUsesArms, systemImage: "figure.stand")
                            ToggleRow(title: "Hops", isOn: $olsHops, systemImage: "figure.stand")
                            ToggleRow(title: "Puts Foot Down", isOn: $olsPutsFootDown, systemImage: "figure.stand")
                        }

                        SummaryCard(title: "One-Leg-Stand Clues", value: "\(totalOLSClues) / 4", systemImage: "list.number")
                    }
                }

                sectionCard(title: "Officer Notes", systemImage: "note.text") {
                    StyledTextEditor(title: "Officer Notes", text: $officerNotes, minHeight: 130)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 7/255, green: 12/255, blue: 24/255),
                    Color(red: 13/255, green: 23/255, blue: 40/255),
                    Color(red: 18/255, green: 29/255, blue: 48/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("SFST Report")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImpliedConsent) {
            IndianaImpliedConsentView()
        }
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

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(.white)

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

struct IndianaImpliedConsentView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Indiana Implied Consent Advisory")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("""
I have probable cause to believe you operated a vehicle while intoxicated.

Indiana law requires that, to comply with implied consent, you submit to each chemical test offered.

If you refuse to submit to the chemical test or tests offered, your driving privileges will be suspended as provided by law.

Refusal may also be used as evidence in court.

Will you submit to the chemical test or tests offered?
""")
                    .foregroundColor(.white.opacity(0.94))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )

                    Text("Verify exact agency-approved wording before field use.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.65))
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 7/255, green: 12/255, blue: 24/255),
                        Color(red: 13/255, green: 23/255, blue: 40/255),
                        Color(red: 18/255, green: 29/255, blue: 48/255)
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
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct StyledTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)

            TextField(title, text: $text)
                .foregroundColor(.white)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        }
    }
}

struct StyledTextEditor: View {
    let title: String
    @Binding var text: String
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)

            ZStack(alignment: .topLeading) {
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(title)
                        .foregroundColor(.white.opacity(0.28))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                }

                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .frame(minHeight: minHeight)
                    .padding(10)
                    .background(Color.clear)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
}

struct StyledDateField: View {
    let title: String
    @Binding var selection: Date
    let displayedComponents: DatePickerComponents

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)

            DatePicker("", selection: $selection, displayedComponents: displayedComponents)
                .labelsHidden()
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        }
    }
}

struct DropdownField: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)

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
                        .foregroundColor(.blue)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

            Text(title)
                .foregroundColor(.white)
                .font(.headline)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct InstructionCard: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(.blue)
                .font(.headline)

            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.white)
                    Text(line)
                        .foregroundColor(.white.opacity(0.92))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.blue.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.blue.opacity(0.25), lineWidth: 1)
        )
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
                .foregroundColor(.white.opacity(0.82))

            Spacer()

            Text(value)
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}
