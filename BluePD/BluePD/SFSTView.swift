import SwiftUI
import UIKit

struct SFSTView: View {
    @EnvironmentObject var storeManager: StoreManager
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
    @State private var showUpgradeAlert = false
    @State private var isPurchasingPro = false
    @State private var saveStatusMessage = ""

    @FocusState private var focusedField: ActiveField?

    enum ActiveField: Hashable {
        case subjectName
        case location
    }

    private let roadOptions = ["Dry", "Wet", "Gravel", "Uneven", "Dirt", "Other"]
    private let lightingOptions = ["Daylight", "Dark - Lit", "Dark - Unlit", "Dawn / Dusk", "Other"]
    private let weatherOptions = ["Clear", "Rain", "Fog", "Snow", "Wind", "Other"]
    private let footwearOptions = ["Barefoot", "Sandals", "Boots", "Tennis Shoes", "Heels", "Other"]

    private let freeReportLimit = 3

    private var hasReachedFreeLimit: Bool {
        !storeManager.isPro && savedReports.count >= freeReportLimit
    }

    private var reportUsageText: String {
        if storeManager.isPro {
            return "BluePD Pro: Unlimited saved reports"
        } else {
            return "\(savedReports.count)/\(freeReportLimit) saved reports used"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                topHeader
                topActionRow

                sectionCard(title: "Subject & Incident", systemImage: "person.text.rectangle.fill") {
                    VStack(spacing: 14) {
                        StyledTextField(
                            title: "Subject Name",
                            text: $subjectName,
                            focusedField: $focusedField,
                            field: .subjectName
                        )

                        HStack(spacing: 14) {
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
                    VStack(spacing: 14) {
                        DropdownField(title: "Road Surface", selection: $roadSurface, options: roadOptions)
                        DropdownField(title: "Lighting", selection: $lighting, options: lightingOptions)
                        DropdownField(title: "Weather", selection: $weather, options: weatherOptions)
                        DropdownField(title: "Footwear", selection: $footwear, options: footwearOptions)
                    }
                }

                sectionCard(title: "Medical / Readiness", systemImage: "cross.case.fill") {
                    VStack(spacing: 12) {
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
                    VStack(spacing: 14) {
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

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Eye Selection")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(BluePDTheme.secondaryText)

                            Picker("Eye", selection: $selectedEye) {
                                Text("Left").tag("Left")
                                Text("Right").tag("Right")
                            }
                            .pickerStyle(.segmented)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }

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
                    VStack(spacing: 12) {
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
                    VStack(spacing: 12) {
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

                saveSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(BluePDTheme.appBackground.ignoresSafeArea())
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
        .sheet(isPresented: $showImpliedConsent) {
            IndianaImpliedConsentView()
        }
        .sheet(isPresented: $showSavedReports) {
            SavedReportsView(savedReports: $savedReports)
        }
        .alert("Upgrade to BluePD Pro", isPresented: $showUpgradeAlert) {
            Button(isPurchasingPro ? "Purchasing..." : "Upgrade") {
                purchasePro()
            }
            .disabled(isPurchasingPro)

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Free users can save up to \(freeReportLimit) reports. Upgrade to BluePD Pro for unlimited saved reports.")
        }
    }

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                BluePDIconContainer(systemImage: "checkmark.shield.fill", size: 56, iconSize: 22)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SFST Report Builder")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(BluePDTheme.primaryText)

                    Text("Document subject details, field conditions, and standardized test clues.")
                        .font(.subheadline)
                        .foregroundStyle(BluePDTheme.secondaryText)
                }

                Spacer()
            }

            Text(reportUsageText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(storeManager.isPro ? BluePDTheme.success : BluePDTheme.primaryText.opacity(0.92))
        }
        .padding(20)
        .bluePDCard(cornerRadius: 24)
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
                    subtitle: savedReportsSubtitle,
                    systemImage: "folder.fill"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var saveSection: some View {
        VStack(spacing: 10) {
            Button {
                attemptSaveReport()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: storeManager.isPro ? "checkmark.seal.fill" : "internaldrive.fill")
                    Text("Save Report to App")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(
                hasReachedFreeLimit
                ? BluePDDisabledButtonStyle()
                : BluePDPrimaryButtonStyle()
            )

            if hasReachedFreeLimit {
                Text("Free report limit reached. Upgrade to BluePD Pro for unlimited saved reports.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BluePDTheme.warning.opacity(0.95))
            }

            if !saveStatusMessage.isEmpty {
                Text(saveStatusMessage)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BluePDTheme.secondaryText)
            }
        }
    }

    private var savedReportsSubtitle: String {
        if storeManager.isPro {
            return "\(savedReports.count) report\(savedReports.count == 1 ? "" : "s") in app • Pro"
        } else {
            return "\(savedReports.count)/\(freeReportLimit) reports used"
        }
    }

    private func attemptSaveReport() {
        saveStatusMessage = ""
        dismissKeyboard()

        if hasReachedFreeLimit {
            showUpgradeAlert = true
            return
        }

        generateReportToApp()
    }

    private func purchasePro() {
        guard !isPurchasingPro else { return }

        isPurchasingPro = true
        saveStatusMessage = "Contacting App Store..."

        Task {
            await storeManager.purchase()

            await MainActor.run {
                isPurchasingPro = false

                if storeManager.isPro {
                    saveStatusMessage = "BluePD Pro unlocked. You now have unlimited saved reports."
                } else {
                    saveStatusMessage = "Purchase was not completed."
                }
            }
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
        saveStatusMessage = "Report saved."
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)
            }

            content()
        }
        .padding(18)
        .bluePDCard(cornerRadius: 24)
    }

    private func rowCard(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            BluePDIconContainer(systemImage: systemImage, size: 46, iconSize: 18)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(BluePDTheme.tertiaryText)
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 20)
    }
}

struct StyledTextField: View {
    let title: String
    @Binding var text: String
    var focusedField: FocusState<SFSTView.ActiveField?>.Binding
    let field: SFSTView.ActiveField

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(BluePDTheme.secondaryText)

            TextField(
                "",
                text: $text,
                prompt: Text(title).foregroundStyle(BluePDTheme.placeholderText)
            )
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .foregroundStyle(BluePDTheme.primaryText)
            .focused(focusedField, equals: field)
            .submitLabel(.done)
            .autocorrectionDisabled()
        }
    }
}

struct StyledDateField: View {
    let title: String
    @Binding var selection: Date
    let displayedComponents: DatePickerComponents

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(BluePDTheme.secondaryText)

            DatePicker(
                "",
                selection: $selection,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .colorScheme(.dark)
        }
    }
}

struct DropdownField: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(BluePDTheme.secondaryText)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection)
                        .foregroundStyle(BluePDTheme.primaryText)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(BluePDTheme.tertiaryText)
                }
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(BluePDTheme.primaryText)
        }
        .tint(BluePDTheme.accent)
        .padding(16)
        .bluePDInnerCard(cornerRadius: 18)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(BluePDTheme.primaryText)

            Spacer()

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(BluePDTheme.accent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.blue.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.blue.opacity(0.22), lineWidth: 1)
                )
        )
    }
}

struct InstructionCard: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(BluePDTheme.primaryText)

            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(BluePDTheme.accent)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)

                    Text(line)
                        .font(.subheadline)
                        .foregroundStyle(BluePDTheme.primaryText.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.blue.opacity(0.11))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.blue.opacity(0.26), lineWidth: 1)
                )
        )
    }
}

struct HGNTimingCard: View {
    let seconds: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(seconds)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text("SEC")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
            }
            .frame(width: 84, height: 84)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.orange.opacity(0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.orange.opacity(0.20), lineWidth: 1)
                    )
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.orange.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.orange.opacity(0.24), lineWidth: 1)
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Text("Indiana Implied Consent")
                            .font(.title2.bold())
                            .foregroundStyle(BluePDTheme.primaryText)

                        Text(showingFront ? "Standard OWI advisory" : "Serious bodily injury / fatal crash advisory")
                            .font(.subheadline)
                            .foregroundStyle(BluePDTheme.secondaryText)
                    }

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
                    }
                    .buttonStyle(BluePDPrimaryButtonStyle())

                    Text("Verify agency-approved wording before operational use.")
                        .font(.footnote)
                        .foregroundStyle(BluePDTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .background(BluePDTheme.appBackground.ignoresSafeArea())
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
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
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
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(90))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
            }
            .frame(width: 72)
        }
        .frame(minHeight: 520)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.blue.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
    }
}
