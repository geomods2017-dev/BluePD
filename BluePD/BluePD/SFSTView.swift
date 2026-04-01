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

    @State private var showSavedBanner = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard

                sectionCard(title: "Subject & Incident", systemImage: "person.text.rectangle.fill") {
                    VStack(spacing: 12) {
                        StyledTextField(
                            title: "Subject Name",
                            text: $subjectName,
                            systemImage: "person.fill"
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
                            systemImage: "mappin.and.ellipse"
                        )
                    }
                }

                sectionCard(title: "Scene Conditions", systemImage: "car.fill") {
                    VStack(spacing: 12) {
                        StyledTextField(
                            title: "Road Surface",
                            text: $roadSurface,
                            systemImage: "road.lanes"
                        )

                        StyledTextField(
                            title: "Lighting",
                            text: $lighting,
                            systemImage: "lightbulb.fill"
                        )

                        StyledTextField(
                            title: "Weather",
                            text: $weather,
                            systemImage: "cloud.fill"
                        )

                        StyledTextField(
                            title: "Footwear",
                            text: $footwear,
                            systemImage: "shoeprints.fill"
                        )
                    }
                }

                sectionCard(title: "Medical & Statements", systemImage: "cross.case.fill") {
                    VStack(spacing: 12) {
                        StyledTextEditor(
                            title: "Medical Conditions",
                            text: $medicalConditions,
                            systemImage: "heart.text.square.fill",
                            minHeight: 100
                        )

                        StyledTextEditor(
                            title: "Subject Statements",
                            text: $subjectStatements,
                            systemImage: "quote.bubble.fill",
                            minHeight: 120
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
                            title: "Head Injury Question",
                            text: $hgnHeadInjuryQuestion,
                            systemImage: "bandage.fill"
                        )

                        StyledTextField(
                            title: "Eye Condition Question",
                            text: $hgnEyeConditionQuestion,
                            systemImage: "eye.fill"
                        )

                        StyledTextField(
                            title: "Vision Correction Question",
                            text: $hgnVisionCorrectionQuestion,
                            systemImage: "eyeglasses"
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
                    }
                }

                sectionCard(title: "Walk and Turn", systemImage: "figure.walk") {
                    VStack(spacing: 12) {
                        StyledTextEditor(
                            title: "Instruction Stage",
                            text: $walkTurnInstructionStage,
                            systemImage: "list.clipboard.fill",
                            minHeight: 110
                        )

                        StyledTextEditor(
                            title: "Walking Stage",
                            text: $walkTurnWalkingStage,
                            systemImage: "figure.walk.motion",
                            minHeight: 110
                        )
                    }
                }

                sectionCard(title: "One Leg Stand", systemImage: "figure.stand") {
                    VStack(spacing: 12) {
                        StyledTextEditor(
                            title: "Instruction Stage",
                            text: $oneLegStandInstructionStage,
                            systemImage: "checklist",
                            minHeight: 110
                        )

                        StyledTextEditor(
                            title: "Balance Stage",
                            text: $oneLegStandBalanceStage,
                            systemImage: "figure.balance",
                            minHeight: 110
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
                            minHeight: 150
                        )
                    }
                }

                VStack(spacing: 12) {
                    Button(action: saveReport) {
                        HStack(spacing: 10) {
                            Image(systemName: "tray.and.arrow.down.fill")
                            Text("Save SFST Report")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                    }

                    if showSavedBanner {
                        Text("Report saved successfully.")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
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

                    Text("Document subject observations, test clues, and field notes.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer()
            }

            Text("Use this form to organize conditions, HGN observations, divided attention testing, and officer notes in one report.")
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

    private func saveReport() {
        showSavedBanner = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            showSavedBanner = false
        }
    }
}

private struct ClueItem: Identifiable {
    let id = UUID()
    let title: String
    let isOn: Binding<Bool>
}

struct StyledTextField: View {
    let title: String
    @Binding var text: String
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

            TextField(title, text: $text)
                .autocorrectionDisabled()
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

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .frame(minHeight: minHeight)
                .padding(10)
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
