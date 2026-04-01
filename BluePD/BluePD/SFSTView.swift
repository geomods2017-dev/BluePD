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

    @State private var hgnRestingNystagmusObserved = false
    @State private var hgnEqualTrackingConfirmed = false
    @State private var hgnEqualPupilSizeConfirmed = false
    @State private var hgnHeadInjuryQuestion = ""
    @State private var hgnEyeConditionQuestion = ""
    @State private var hgnVisionCorrectionQuestion = ""

    @State private var hgnLeftLackOfSmoothPursuit = false
    @State private var hgnLeftDistinctNystagmus = false
    @State private var hgnLeftOnsetPriorTo45 = false
    @State private var hgnRightLackOfSmoothPursuit = false
    @State private var hgnRightDistinctNystagmus = false
    @State private var hgnRightOnsetPriorTo45 = false

    @State private var walkTurnInstructionStage = ""
    @State private var walkTurnWalkingStage = ""
    @State private var oneLegStandInstructionStage = ""
    @State private var oneLegStandBalanceStage = ""

    @State private var showingSaveAlert = false
    @State private var saveAlertTitle = ""
    @State private var saveAlertMessage = ""

    @State private var showingResetAlert = false

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case subjectName
        case location
        case roadSurface
        case lighting
        case weather
        case footwear
        case medicalConditions
        case subjectStatements
        case headInjuryQuestion
        case eyeConditionQuestion
        case visionCorrectionQuestion
        case walkTurnInstructionStage
        case walkTurnWalkingStage
        case oneLegStandInstructionStage
        case oneLegStandBalanceStage
        case officerNotes
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard

                sectionCard(title: "Subject & Incident", systemImage: "person.text.rectangle.fill") {
                    VStack(spacing: 12) {
                        StyledTextField(
                            title: "Subject Name",
                            text: $subjectName,
                            systemImage: "person.fill",
                            focusedField: $focusedField,
                            equals: .subjectName
                        )

                        HStack(spacing: 12) {
                            StyledDateField(
                                title: "Incident Date",
                                selection: $incidentDate,
                                displayedComponents: .date,
                                systemImage: "calendar"
                            )

                            StyledDateField(
                                title: "Incident Time",
                                selection: $incidentTime,
                                displayedComponents: .hourAndMinute,
                                systemImage: "clock.fill"
                            )
                        }

                        StyledTextField(
                            title: "Location",
                            text: $location,
                            systemImage: "mappin.and.ellipse",
                            focusedField: $focusedField,
                            equals: .location
                        )
                    }
                }

                sectionCard(title: "Scene Conditions", systemImage: "car.fill") {
                    VStack(spacing: 12) {
                        StyledTextField(
                            title: "Road Surface",
                            text: $roadSurface,
                            systemImage: "road.lanes",
                            focusedField: $focusedField,
                            equals: .roadSurface
                        )

                        StyledTextField(
                            title: "Lighting",
                            text: $lighting,
                            systemImage: "lightbulb.fill",
                            focusedField: $focusedField,
                            equals: .lighting
                        )

                        StyledTextField(
                            title: "Weather",
                            text: $weather,
                            systemImage: "cloud.fill",
                            focusedField: $focusedField,
                            equals: .weather
                        )

                        StyledTextField(
                            title: "Footwear",
                            text: $footwear,
                            systemImage: "shoeprints.fill",
                            focusedField: $focusedField,
                            equals: .footwear
                        )
                    }
                }

                sectionCard(title: "Medical & Statements", systemImage: "cross.case.fill") {
                    VStack(spacing: 12) {
                        StyledTextEditor(
                            title: "Medical Conditions",
                            text: $medicalConditions,
                            systemImage: "heart.text.square.fill",
                            minHeight: 100,
                            focusedField: $focusedField,
                            equals: .medicalConditions
                        )

                        StyledTextEditor(
                            title: "Subject Statements",
                            text: $subjectStatements,
                            systemImage: "quote.bubble.fill",
                            minHeight: 120,
                            focusedField: $focusedField,
                            equals: .subjectStatements
                        )
                    }
                }

                sectionCard(title: "HGN Pre-Test Screening", systemImage: "eye.fill") {
                    VStack(spacing: 12) {
                        ToggleRow(
                            title: "Resting Nystagmus Observed",
                            subtitle: "Observed before test began.",
                            isOn: $hgnRestingNystagmusObserved,
                            systemImage: "eye.trianglebadge.exclamationmark"
                        )

                        ToggleRow(
                            title: "Equal Tracking Confirmed",
                            subtitle: "Eyes tracked equally during screening.",
                            isOn: $hgnEqualTrackingConfirmed,
                            systemImage: "arrow.left.and.right.righttriangle.left.righttriangle.right"
                        )

                        ToggleRow(
                            title: "Equal Pupil Size Confirmed",
                            subtitle: "No noticeable unequal pupil size.",
                            isOn: $hgnEqualPupilSizeConfirmed,
                            systemImage: "circle.lefthalf.filled"
                        )

                        StyledTextField(
                            title: "Head Injury Question / Response",
                            text: $hgnHeadInjuryQuestion,
                            systemImage: "bandage.fill",
                            focusedField: $focusedField,
                            equals: .headInjuryQuestion
                        )

                        StyledTextField(
                            title: "Eye Condition Question / Response",
                            text: $hgnEyeConditionQuestion,
                            systemImage: "eye.fill",
                            focusedField: $focusedField,
                            equals: .eyeConditionQuestion
                        )

                        StyledTextField(
                            title: "Vision Correction Question / Response",
                            text: $hgnVisionCorrectionQuestion,
                            systemImage: "eyeglasses",
                            focusedField: $focusedField,
                            equals: .visionCorrectionQuestion
                        )
                    }
                }

                sectionCard(title: "HGN Clues", systemImage: "eye.circle.fill") {
                    VStack(spacing: 14) {
                        clueGroup(
                            title: "Left Eye",
                            items: [
                                clueBinding("Lack of Smooth Pursuit", $hgnLeftLackOfSmoothPursuit),
                                clueBinding("Distinct Nystagmus at Maximum Deviation", $hgnLeftDistinctNystagmus),
                                clueBinding("Onset of Nystagmus Prior to 45°", $hgnLeftOnsetPriorTo45)
                            ]
                        )

                        clueGroup(
                            title: "Right Eye",
                            items: [
                                clueBinding("Lack of Smooth Pursuit", $hgnRightLackOfSmoothPursuit),
                                clueBinding("Distinct Nystagmus at Maximum Deviation", $hgnRightDistinctNystagmus),
                                clueBinding("Onset of Nystagmus Prior to 45°", $hgnRightOnsetPriorTo45)
                            ]
                        )

                        summaryStatCard(
                            title: "Total HGN Clues",
                            value: "\(totalHGNClues)/6",
                            systemImage: "waveform.path.ecg"
                        )
                    }
                }

                sectionCard(title: "Walk and Turn", systemImage: "figure.walk") {
                    VStack(spacing: 12) {
                        instructionButtonRow(
                            buttonTitle: "Restore Walk-and-Turn Instructions",
                            systemImage: "arrow.clockwise",
                            action: insertWalkTurnInstructions
                        )

                        StyledTextEditor(
                            title: "Instruction Stage",
                            text: $walkTurnInstructionStage,
                            systemImage: "list.clipboard.fill",
                            minHeight: 170,
                            focusedField: $focusedField,
                            equals: .walkTurnInstructionStage
                        )

                        StyledTextEditor(
                            title: "Walking Stage / Observations",
                            text: $walkTurnWalkingStage,
                            systemImage: "figure.walk.motion",
                            minHeight: 150,
                            focusedField: $focusedField,
                            equals: .walkTurnWalkingStage
                        )
                    }
                }

                sectionCard(title: "One Leg Stand", systemImage: "figure.stand") {
                    VStack(spacing: 12) {
                        instructionButtonRow(
                            buttonTitle: "Restore One-Leg-Stand Instructions",
                            systemImage: "arrow.clockwise",
                            action: insertOneLegStandInstructions
                        )

                        StyledTextEditor(
                            title: "Instruction Stage",
                            text: $oneLegStandInstructionStage,
                            systemImage: "checklist",
                            minHeight: 170,
                            focusedField: $focusedField,
                            equals: .oneLegStandInstructionStage
                        )

                        StyledTextEditor(
                            title: "Balance Stage / Observations",
                            text: $oneLegStandBalanceStage,
                            systemImage: "figure.balance",
                            minHeight: 150,
                            focusedField: $focusedField,
                            equals: .oneLegStandBalanceStage
                        )
                    }
                }

                sectionCard(title: "Officer Notes", systemImage: "note.text.badge.plus") {
                    VStack(spacing: 12) {
                        if autoFillOfficerInfo {
                            officerInfoCard
                        }

                        StyledTextEditor(
                            title: "Officer Notes",
                            text: $officerNotes,
                            systemImage: "square.and.pencil",
                            minHeight: 150,
                            focusedField: $focusedField,
                            equals: .officerNotes
                        )
                    }
                }

                sectionCard(title: "Generated Narrative", systemImage: "doc.text.fill") {
                    Text(generatedNarrative)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.88))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                        )
                }

                VStack(spacing: 12) {
                    Button(action: saveReport) {
                        actionButtonLabel(
                            title: "Save SFST Report",
                            systemImage: "tray.and.arrow.down.fill"
                        )
                    }

                    Button(action: resetForm) {
                        actionButtonLabel(
                            title: "Clear Form",
                            systemImage: "trash.fill",
                            fillColor: .red
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .onAppear {
            loadDefaultInstructionsIfNeeded()
        }
        .alert(saveAlertTitle, isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveAlertMessage)
        }
        .alert("Clear this report?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllFields()
            }
        } message: {
            Text("This will remove all entered SFST information from the screen.")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue.opacity(0.16))
                        .frame(width: 58, height: 58)

                    Image(systemName: "car.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Standardized Field Sobriety Test")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Document observations, clues, divided-attention testing, and officer notes.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer()
            }

            Text("Restores built-in instructions, fixes keyboard issues, and saves report files locally.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
    }

    private var officerInfoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("Stored Officer Information")
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "person.crop.rectangle.fill")
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 6) {
                infoLine("Officer", officerName)
                infoLine("Badge", badgeNumber)
                infoLine("Agency", agencyName)
                infoLine("Rank", officerRank)
                infoLine("Unit", officerUnit)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func infoLine(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(title):")
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(value.isEmpty ? "Not Set" : value)
                .foregroundColor(.white.opacity(0.78))

            Spacer()
        }
        .font(.subheadline)
    }

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

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

    private func instructionButtonRow(
        buttonTitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                Text(buttonTitle)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.blue.opacity(0.24), lineWidth: 1)
            )
        }
        .foregroundColor(.blue)
    }

    private func actionButtonLabel(
        title: String,
        systemImage: String,
        fillColor: Color = .blue
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(title)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(fillColor)
        )
        .foregroundColor(.white)
    }

    private func summaryStatCard(title: String, value: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .foregroundColor(.white.opacity(0.82))
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func clueBinding(_ title: String, _ binding: Binding<Bool>) -> ClueItem {
        ClueItem(title: title, isOn: binding)
    }

    private func clueGroup(title: String, items: [ClueItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            ForEach(items) { item in
                ToggleRow(
                    title: item.title,
                    subtitle: "Mark if observed during testing.",
                    isOn: item.isOn,
                    systemImage: "checkmark.shield.fill"
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
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

    private var combinedIncidentDateTime: Date {
        let calendar = Calendar.current
        let dateParts = calendar.dateComponents([.year, .month, .day], from: incidentDate)
        let timeParts = calendar.dateComponents([.hour, .minute], from: incidentTime)

        var combined = DateComponents()
        combined.year = dateParts.year
        combined.month = dateParts.month
        combined.day = dateParts.day
        combined.hour = timeParts.hour
        combined.minute = timeParts.minute

        return calendar.date(from: combined) ?? Date()
    }

    private var generatedNarrative: String {
        let dateText = Self.reportDateFormatter.string(from: combinedIncidentDateTime)
        let subject = subjectName.trimmedOrFallback("the subject")
        let locationText = location.trimmedOrFallback("an unspecified location")
        let road = roadSurface.trimmedOrFallback("not documented")
        let light = lighting.trimmedOrFallback("not documented")
        let weatherText = weather.trimmedOrFallback("not documented")
        let shoeText = footwear.trimmedOrFallback("not documented")

        return """
        On \(dateText), SFST observations were documented for \(subject) at \(locationText). Scene conditions included road surface: \(road), lighting: \(light), weather: \(weatherText), and footwear: \(shoeText).

        HGN pre-test screening noted resting nystagmus observed: \(yesNo(hgnRestingNystagmusObserved)), equal tracking confirmed: \(yesNo(hgnEqualTrackingConfirmed)), and equal pupil size confirmed: \(yesNo(hgnEqualPupilSizeConfirmed)). Total HGN clues observed: \(totalHGNClues) of 6.

        Walk-and-Turn observations: \(walkTurnWalkingStage.trimmedOrFallback("No walk-and-turn observations entered."))

        One-Leg-Stand observations: \(oneLegStandBalanceStage.trimmedOrFallback("No one-leg-stand observations entered."))

        Subject statements: \(subjectStatements.trimmedOrFallback("None documented."))

        Medical conditions or considerations: \(medicalConditions.trimmedOrFallback("None documented."))

        Officer notes: \(officerNotes.trimmedOrFallback("None documented."))
        """
    }

    private func yesNo(_ value: Bool) -> String {
        value ? "Yes" : "No"
    }

    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func loadDefaultInstructionsIfNeeded() {
        if walkTurnInstructionStage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            insertWalkTurnInstructions()
        }

        if oneLegStandInstructionStage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            insertOneLegStandInstructions()
        }
    }

    private func insertWalkTurnInstructions() {
        walkTurnInstructionStage = """
        • Place your left foot on the line and your right foot in front of it, heel-to-toe.
        • Keep your arms at your sides and remain in this position while instructions are given.
        • Do not start until told to begin.
        • When told to begin, take 9 heel-to-toe steps on the line.
        • On the 9th step, keep your front foot on the line and turn using a series of small steps.
        • Return with 9 heel-to-toe steps.
        • Count the steps out loud.
        • Watch your feet while walking.
        • Keep your arms at your sides.
        • Do not stop once you begin until the test is completed.
        """
    }

    private func insertOneLegStandInstructions() {
        oneLegStandInstructionStage = """
        • Stand with your feet together and your arms at your sides.
        • Do not begin until told to do so.
        • When told to begin, raise one foot approximately six inches off the ground, keeping the raised foot parallel to the ground.
        • Keep both legs straight and look at the raised foot.
        • Count out loud in the following manner: one thousand one, one thousand two, one thousand three, and so on until told to stop.
        • Keep your arms at your sides during the test.
        """
    }

    private func saveReport() {
        dismissKeyboard()

        let report = SFSTReport(
            id: UUID(),
            createdAt: Date(),
            subjectName: subjectName,
            incidentDate: incidentDate,
            incidentTime: incidentTime,
            location: location,
            roadSurface: roadSurface,
            lighting: lighting,
            weather: weather,
            footwear: footwear,
            medicalConditions: medicalConditions,
            subjectStatements: subjectStatements,
            officerNotes: officerNotes,
            officerName: officerName,
            badgeNumber: badgeNumber,
            agencyName: agencyName,
            officerRank: officerRank,
            officerUnit: officerUnit,
            autoFillOfficerInfo: autoFillOfficerInfo,
            hgnRestingNystagmusObserved: hgnRestingNystagmusObserved,
            hgnEqualTrackingConfirmed: hgnEqualTrackingConfirmed,
            hgnEqualPupilSizeConfirmed: hgnEqualPupilSizeConfirmed,
            hgnHeadInjuryQuestion: hgnHeadInjuryQuestion,
            hgnEyeConditionQuestion: hgnEyeConditionQuestion,
            hgnVisionCorrectionQuestion: hgnVisionCorrectionQuestion,
            hgnLeftLackOfSmoothPursuit: hgnLeftLackOfSmoothPursuit,
            hgnLeftDistinctNystagmus: hgnLeftDistinctNystagmus,
            hgnLeftOnsetPriorTo45: hgnLeftOnsetPriorTo45,
            hgnRightLackOfSmoothPursuit: hgnRightLackOfSmoothPursuit,
            hgnRightDistinctNystagmus: hgnRightDistinctNystagmus,
            hgnRightOnsetPriorTo45: hgnRightOnsetPriorTo45,
            walkTurnInstructionStage: walkTurnInstructionStage,
            walkTurnWalkingStage: walkTurnWalkingStage,
            oneLegStandInstructionStage: oneLegStandInstructionStage,
            oneLegStandBalanceStage: oneLegStandBalanceStage,
            generatedNarrative: generatedNarrative
        )

        do {
            let baseFileName = buildFileName()
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let jsonURL = documentsURL.appendingPathComponent("\(baseFileName).json")
            let textURL = documentsURL.appendingPathComponent("\(baseFileName).txt")

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601

            let jsonData = try encoder.encode(report)
            try jsonData.write(to: jsonURL, options: .atomic)

            let textData = reportText(report).data(using: .utf8) ?? Data()
            try textData.write(to: textURL, options: .atomic)

            saveAlertTitle = "Report Saved"
            saveAlertMessage = "Saved \(baseFileName).json and \(baseFileName).txt to the app’s Documents folder."
            showingSaveAlert = true
        } catch {
            saveAlertTitle = "Save Failed"
            saveAlertMessage = error.localizedDescription
            showingSaveAlert = true
        }
    }

    private func reportText(_ report: SFSTReport) -> String {
        """
        SFST REPORT
        ==============================

        Subject Name: \(report.subjectName.trimmedOrFallback("Not entered"))
        Incident Date/Time: \(Self.reportDateFormatter.string(from: combinedIncidentDateTime))
        Location: \(report.location.trimmedOrFallback("Not entered"))

        SCENE CONDITIONS
        ------------------------------
        Road Surface: \(report.roadSurface.trimmedOrFallback("Not entered"))
        Lighting: \(report.lighting.trimmedOrFallback("Not entered"))
        Weather: \(report.weather.trimmedOrFallback("Not entered"))
        Footwear: \(report.footwear.trimmedOrFallback("Not entered"))

        MEDICAL / STATEMENTS
        ------------------------------
        Medical Conditions: \(report.medicalConditions.trimmedOrFallback("None documented"))
        Subject Statements: \(report.subjectStatements.trimmedOrFallback("None documented"))

        HGN PRE-TEST SCREENING
        ------------------------------
        Resting Nystagmus Observed: \(yesNo(report.hgnRestingNystagmusObserved))
        Equal Tracking Confirmed: \(yesNo(report.hgnEqualTrackingConfirmed))
        Equal Pupil Size Confirmed: \(yesNo(report.hgnEqualPupilSizeConfirmed))
        Head Injury Question / Response: \(report.hgnHeadInjuryQuestion.trimmedOrFallback("Not documented"))
        Eye Condition Question / Response: \(report.hgnEyeConditionQuestion.trimmedOrFallback("Not documented"))
        Vision Correction Question / Response: \(report.hgnVisionCorrectionQuestion.trimmedOrFallback("Not documented"))

        HGN CLUES
        ------------------------------
        Left Eye - Lack of Smooth Pursuit: \(yesNo(report.hgnLeftLackOfSmoothPursuit))
        Left Eye - Distinct Nystagmus at Maximum Deviation: \(yesNo(report.hgnLeftDistinctNystagmus))
        Left Eye - Onset Prior to 45°: \(yesNo(report.hgnLeftOnsetPriorTo45))
        Right Eye - Lack of Smooth Pursuit: \(yesNo(report.hgnRightLackOfSmoothPursuit))
        Right Eye - Distinct Nystagmus at Maximum Deviation: \(yesNo(report.hgnRightDistinctNystagmus))
        Right Eye - Onset Prior to 45°: \(yesNo(report.hgnRightOnsetPriorTo45))
        Total HGN Clues: \(totalHGNClues) / 6

        WALK AND TURN
        ------------------------------
        Instruction Stage:
        \(report.walkTurnInstructionStage.trimmedOrFallback("Not documented"))

        Walking Stage / Observations:
        \(report.walkTurnWalkingStage.trimmedOrFallback("Not documented"))

        ONE LEG STAND
        ------------------------------
        Instruction Stage:
        \(report.oneLegStandInstructionStage.trimmedOrFallback("Not documented"))

        Balance Stage / Observations:
        \(report.oneLegStandBalanceStage.trimmedOrFallback("Not documented"))

        OFFICER INFORMATION
        ------------------------------
        Officer: \(report.officerName.trimmedOrFallback("Not entered"))
        Badge Number: \(report.badgeNumber.trimmedOrFallback("Not entered"))
        Agency: \(report.agencyName.trimmedOrFallback("Not entered"))
        Rank: \(report.officerRank.trimmedOrFallback("Not entered"))
        Unit: \(report.officerUnit.trimmedOrFallback("Not entered"))
        Auto Fill Enabled: \(yesNo(report.autoFillOfficerInfo))

        OFFICER NOTES
        ------------------------------
        \(report.officerNotes.trimmedOrFallback("None documented"))

        GENERATED NARRATIVE
        ------------------------------
        \(report.generatedNarrative)
        """
    }

    private func buildFileName() -> String {
        let cleanSubject = subjectName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")

        let subjectPart = cleanSubject.isEmpty ? "UnknownSubject" : cleanSubject
        let timeStamp = Self.fileDateFormatter.string(from: combinedIncidentDateTime)
        return "SFST_\(subjectPart)_\(timeStamp)"
    }

    private func resetForm() {
        dismissKeyboard()
        showingResetAlert = true
    }

    private func clearAllFields() {
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

        hgnRestingNystagmusObserved = false
        hgnEqualTrackingConfirmed = false
        hgnEqualPupilSizeConfirmed = false
        hgnHeadInjuryQuestion = ""
        hgnEyeConditionQuestion = ""
        hgnVisionCorrectionQuestion = ""

        hgnLeftLackOfSmoothPursuit = false
        hgnLeftDistinctNystagmus = false
        hgnLeftOnsetPriorTo45 = false
        hgnRightLackOfSmoothPursuit = false
        hgnRightDistinctNystagmus = false
        hgnRightOnsetPriorTo45 = false

        walkTurnInstructionStage = ""
        walkTurnWalkingStage = ""
        oneLegStandInstructionStage = ""
        oneLegStandBalanceStage = ""

        loadDefaultInstructionsIfNeeded()
    }

    private static let reportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static let fileDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmm"
        return formatter
    }()
}

private struct SFSTReport: Codable {
    let id: UUID
    let createdAt: Date

    let subjectName: String
    let incidentDate: Date
    let incidentTime: Date
    let location: String
    let roadSurface: String
    let lighting: String
    let weather: String
    let footwear: String
    let medicalConditions: String
    let subjectStatements: String
    let officerNotes: String

    let officerName: String
    let badgeNumber: String
    let agencyName: String
    let officerRank: String
    let officerUnit: String
    let autoFillOfficerInfo: Bool

    let hgnRestingNystagmusObserved: Bool
    let hgnEqualTrackingConfirmed: Bool
    let hgnEqualPupilSizeConfirmed: Bool
    let hgnHeadInjuryQuestion: String
    let hgnEyeConditionQuestion: String
    let hgnVisionCorrectionQuestion: String

    let hgnLeftLackOfSmoothPursuit: Bool
    let hgnLeftDistinctNystagmus: Bool
    let hgnLeftOnsetPriorTo45: Bool
    let hgnRightLackOfSmoothPursuit: Bool
    let hgnRightDistinctNystagmus: Bool
    let hgnRightOnsetPriorTo45: Bool

    let walkTurnInstructionStage: String
    let walkTurnWalkingStage: String
    let oneLegStandInstructionStage: String
    let oneLegStandBalanceStage: String

    let generatedNarrative: String
}

private struct ClueItem: Identifiable {
    let id = UUID()
    let title: String
    let isOn: Binding<Bool>
}

private extension String {
    func trimmedOrFallback(_ fallback: String) -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

struct StyledTextField: View {
    let title: String
    @Binding var text: String
    let systemImage: String
    let focusedField: FocusState<SFSTView.Field?>.Binding
    let equals: SFSTView.Field

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.78))
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

            TextField(title, text: $text, axis: .vertical)
                .focused(focusedField, equals: equals)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
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
    let systemImage: String
    let minHeight: CGFloat
    let focusedField: FocusState<SFSTView.Field?>.Binding
    let equals: SFSTView.Field

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.78))
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

            ZStack(alignment: .topLeading) {
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(title)
                        .foregroundColor(.white.opacity(0.28))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                }

                TextEditor(text: $text)
                    .focused(focusedField, equals: equals)
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
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.78))
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
            }

            DatePicker(
                "",
                selection: $selection,
                displayedComponents: displayedComponents
            )
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

struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.68))
            }

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
