import SwiftUI
import UIKit

struct SFSTView: View {
    @Binding var savedReports: [SavedSFSTReport]

    @State private var subjectName = ""
    @State private var incidentDate = Date()
    @State private var incidentTime = Date()
    @State private var location = ""

    @State private var roadSurface = "Dry"
    @State private var lighting = "Daylight"
    @State private var weather = "Clear"
    @State private var footwear = "Tennis Shoes"

    @State private var subjectDeniesMedicalIssues = false
    @State private var subjectAdmitsMedicalIssues = false
    @State private var headInjuryIndicated = false
    @State private var eyeConditionIndicated = false
    @State private var legOrBackProblemIndicated = false
    @State private var subjectWearsContacts = false
    @State private var subjectWearsGlasses = false
    @State private var instructionsUnderstood = true

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
    @State private var showSavedReports = false

    @FocusState private var focusedField: ActiveField?

    enum ActiveField: Hashable {
        case subjectName
        case location
    }

    private let roadOptions = ["Dry", "Wet", "Gravel", "Uneven", "Dirt", "Other"]
    private let lightingOptions = ["Daylight", "Dark - Lit", "Dark - Unlit", "Dawn / Dusk", "Other"]
    private let weatherOptions = ["Clear", "Rain", "Fog", "Snow", "Wind", "Other"]
    private let footwearOptions = ["Barefoot", "Sandals", "Boots", "Tennis Shoes", "Heels", "Other"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                topActionRow

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

                sectionCard(title: "Medical / Readiness", systemImage: "cross.case.fill") {
                    VStack(spacing: 10) {
                        InstructionCard(
                            title: "Pre-Test Reminders",
                            lines: [
                                "Ask about injuries, medical conditions, and vision issues before beginning.",
                                "Confirm the subject understands instructions.",
                                "Note any condition that may affect balance, coordination, or eye movement."
                            ]
                        )

                        ToggleRow(title: "Subject Denies Medical Issues", isOn: $subjectDeniesMedicalIssues)
                        ToggleRow(title: "Subject Admits Medical Issues", isOn: $subjectAdmitsMedicalIssues)
                        ToggleRow(title: "Head Injury Indicated", isOn: $headInjuryIndicated)
                        ToggleRow(title: "Eye Condition Indicated", isOn: $eyeConditionIndicated)
                        ToggleRow(title: "Leg / Back Problem Indicated", isOn: $legOrBackProblemIndicated)
                        ToggleRow(title: "Subject Wears Contacts", isOn: $subjectWearsContacts)
                        ToggleRow(title: "Subject Wears Glasses", isOn: $subjectWearsGlasses)
                        ToggleRow(title: "Instructions Understood", isOn: $instructionsUnderstood)
                    }
                }

                sectionCard(title: "HGN", systemImage: "eye.fill") {
                    VStack(spacing: 12) {
                        InstructionCard(
                            title: "Officer Setup",
                            lines: [
                                "Confirm the subject understands instructions.",
                                "Remove distractions when practical.",
                                "Position the stimulus approximately 12–15 inches from the subject’s face.",
                                "Hold the stimulus slightly above eye level.",
                                "Tell the subject to keep the head still and follow the stimulus with the eyes only."
                            ]
                        )

                        HGNTimingCard(
                            seconds: "2",
                            title: "Lack of Smooth Pursuit",
                            subtitle: "Move from center to side in about 2 seconds, then return in about 2 seconds."
                        )

                        HGNTimingCard(
                            seconds: "4",
                            title: "Maximum Deviation",
                            subtitle: "Move to maximum deviation and hold for at least 4 seconds."
                        )

                        HGNTimingCard(
                            seconds: "4",
                            title: "Onset Prior to 45°",
                            subtitle: "Move slowly from center to side in about 4 seconds."
                        )

                        ToggleRow(title: "Resting Nystagmus", isOn: $hgnRestingNystagmusObserved)
                        ToggleRow(title: "Equal Tracking", isOn: $hgnEqualTrackingConfirmed)
                        ToggleRow(title: "Equal Pupil Size", isOn: $hgnEqualPupilSizeConfirmed)

                        Picker("Eye", selection: $selectedEye) {
                            Text("Left").tag("Left")
                            Text("Right").tag("Right")
                        }
                        .pickerStyle(.segmented)
                        .padding(6)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

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
                        ToggleRow(title: "Wrong Number of Steps", isOn: $watWrongNumberOfSteps)

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
                        ToggleRow(title: "Puts Foot Down", isOn: $olsPutsFootDown)

                        SummaryCard(title: "OLS Clues", value: "\(totalOLSClues)/4")
                    }
                }

                Button(action: generateReportToApp) {
                    HStack {
                        Image(systemName: "internaldrive.fill")
                        Text("Save Report to App")
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
        .sheet(isPresented: $showSavedReports) {
            SavedReportsView(savedReports: $savedReports)
        }
    }

    private var topActionRow: some View {
        VStack(spacing: 12) {
            Button {
                dismissKeyboard()
                showImpliedConsent = true
            } label: {
                rowCard(
                    title: "Indiana Implied Consent",
                    subtitle: "Open flip card",
                    systemImage: "doc.text.fill"
                )
            }
            .buttonStyle(.plain)

            Button {
                dismissKeyboard()
                showSavedReports = true
            } label: {
                rowCard(
                    title: "Saved Reports",
                    subtitle: "\(savedReports.count) report\(savedReports.count == 1 ? "" : "s") in app",
                    systemImage: "folder.fill"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func generateReportToApp() {
        dismissKeyboard()

        let reportBody = """
        SFST REPORT

        Subject: \(subjectName.isEmpty ? "N/A" : subjectName)
        Date: \(incidentDate.formatted(date: .abbreviated, time: .omitted))
        Time: \(incidentTime.formatted(date: .omitted, time: .shortened))
        Location: \(location.isEmpty ? "N/A" : location)

        SCENE CONDITIONS
        Road Surface: \(roadSurface)
        Lighting: \(lighting)
        Weather: \(weather)
        Footwear: \(footwear)

        MEDICAL / READINESS
        Subject Denies Medical Issues: \(yesNo(subjectDeniesMedicalIssues))
        Subject Admits Medical Issues: \(yesNo(subjectAdmitsMedicalIssues))
        Head Injury Indicated: \(yesNo(headInjuryIndicated))
        Eye Condition Indicated: \(yesNo(eyeConditionIndicated))
        Leg / Back Problem Indicated: \(yesNo(legOrBackProblemIndicated))
        Subject Wears Contacts: \(yesNo(subjectWearsContacts))
        Subject Wears Glasses: \(yesNo(subjectWearsGlasses))
        Instructions Understood: \(yesNo(instructionsUnderstood))

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
        Puts Foot Down: \(yesNo(olsPutsFootDown))
        Total OLS Clues: \(totalOLSClues)/4
        """

        let newReport = SavedSFSTReport(
            subjectName: subjectName.isEmpty ? "Unnamed Subject" : subjectName,
            reportText: reportBody
        )

        savedReports.insert(newReport, at: 0)
        showSavedReports = true
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

            VStack(alignment: .leading, spacing: 4) {
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
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.blue.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                )
        )
    }
}

struct HGNTimingCard: View {
    let seconds: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(seconds)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("SEC")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 84, height: 84)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.orange.opacity(0.22))
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.orange.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct IndianaImpliedConsentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFront = true

    private let frontText = """
I HAVE PROBABLE CAUSE TO BELIEVE THAT YOU HAVE OPERATED A VEHICLE WHILE INTOXICATED. I MUST NOW OFFER YOU THE OPPORTUNITY TO SUBMIT TO A CHEMICAL TEST AND INFORM YOU THAT YOUR REFUSAL TO SUBMIT TO A CHEMICAL TEST WILL RESULT IN THE SUSPENSION OF YOUR DRIVING PRIVILEGES FOR ONE YEAR. IF YOU HAVE AT LEAST ONE PREVIOUS CONVICTION FOR OPERATING WHILE INTOXICATED, YOUR REFUSAL TO SUBMIT TO A CHEMICAL TEST WILL RESULT IN THE SUSPENSION OF YOUR DRIVING PRIVILEGES FOR TWO YEARS.

WILL YOU NOW TAKE A CHEMICAL TEST?
"""

    private let backText = """
I HAVE REASON TO BELIEVE THAT YOU HAVE OPERATED A VEHICLE THAT WAS INVOLVED IN A FATAL OR SERIOUS BODILY INJURY CRASH. I MUST NOW OFFER YOU THE OPPORTUNITY TO SUBMIT TO A CHEMICAL TEST AND INFORM YOU THAT YOUR REFUSAL TO SUBMIT TO A CHEMICAL TEST WILL RESULT IN THE SUSPENSION OF YOUR DRIVING PRIVILEGES FOR ONE YEAR AND IS PUNISHABLE AS A CLASS C INFRACTION. IF YOU HAVE AT LEAST ONE PREVIOUS CONVICTION FOR OPERATING WHILE INTOXICATED, YOUR REFUSAL TO SUBMIT TO A CHEMICAL TEST WILL RESULT IN THE SUSPENSION OF YOUR DRIVING PRIVILEGES FOR TWO YEARS AND IS PUNISHABLE AS A CLASS A INFRACTION.

WILL YOU NOW TAKE A CHEMICAL TEST?
"""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Indiana Implied Consent")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(showingFront ? "Standard OWI advisory" : "Serious bodily injury / fatal crash advisory")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    ZStack {
                        if showingFront {
                            ImpliedConsentCard(
                                sideLabel: "IMPLIED CONSENT",
                                text: frontText
                            )
                            .transition(.opacity)
                        } else {
                            ImpliedConsentCard(
                                sideLabel: "IMPLIED CONSENT - SBI",
                                text: backText
                            )
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: showingFront)

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingFront.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text(showingFront ? "Flip to Back" : "Flip to Front")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }

                    Text("Verify agency-approved wording before operational use.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
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

struct ImpliedConsentCard: View {
    let sideLabel: String
    let text: String

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()

                Text(text)
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .minimumScaleFactor(0.55)
                    .padding(24)

                Spacer()
            }
            .frame(maxWidth: .infinity)

            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(0.08))

                Text(sideLabel)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(90))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
            }
            .frame(width: 72)
        }
        .frame(minHeight: 520)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.blue.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
    }
}
