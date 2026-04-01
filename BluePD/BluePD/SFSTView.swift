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

    @State private var officerNotes = ""

    @State private var selectedEye = "Left"

    @State private var hgnLeft = [false, false, false]
    @State private var hgnRight = [false, false, false]

    @State private var watClues = Array(repeating: false, count: 8)
    @State private var olsClues = Array(repeating: false, count: 4)

    @State private var showImpliedConsent = false

    private let roadOptions = ["Dry","Wet","Gravel","Uneven","Dirt","Other"]
    private let lightingOptions = ["Daylight","Dark - Lit","Dark - Unlit","Dawn/Dusk","Other"]
    private let weatherOptions = ["Clear","Rain","Fog","Snow","Wind","Other"]
    private let footwearOptions = ["Barefoot","Sandals","Boots","Tennis Shoes","Heels","Other"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // IMPLIED CONSENT QUICK ACCESS
                Button {
                    showImpliedConsent = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Indiana Implied Consent")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                }
                .foregroundColor(.white)

                section("Subject") {
                    StyledTextField(title: "Name", text: $subjectName)
                    StyledTextField(title: "Location", text: $location)
                }

                section("Conditions") {
                    DropdownField(title: "Road", selection: $roadSurface, options: roadOptions)
                    DropdownField(title: "Lighting", selection: $lighting, options: lightingOptions)
                    DropdownField(title: "Weather", selection: $weather, options: weatherOptions)
                    DropdownField(title: "Footwear", selection: $footwear, options: footwearOptions)
                }

                section("HGN") {
                    Picker("", selection: $selectedEye) {
                        Text("Left").tag("Left")
                        Text("Right").tag("Right")
                    }
                    .pickerStyle(.segmented)

                    if selectedEye == "Left" {
                        toggleList(["Smooth Pursuit","Distinct Nystagmus","Onset <45°"], bindings: $hgnLeft)
                    } else {
                        toggleList(["Smooth Pursuit","Distinct Nystagmus","Onset <45°"], bindings: $hgnRight)
                    }

                    stat("HGN Clues", "\(totalHGN)/6")
                }

                section("Walk & Turn") {
                    instructionCard([
                        "9 heel-to-toe steps",
                        "Keep arms at sides",
                        "Watch feet",
                        "Turn using small steps"
                    ])

                    toggleList([
                        "Balance","Starts Early","Stops",
                        "Misses Heel-To-Toe","Off Line",
                        "Uses Arms","Bad Turn","Wrong Steps"
                    ], bindings: $watClues)

                    stat("WAT", "\(totalWAT)/8")
                }

                section("One Leg Stand") {
                    instructionCard([
                        "Raise foot 6 inches",
                        "Keep arms at sides",
                        "Count out loud"
                    ])

                    toggleList(["Sways","Uses Arms","Hops","Foot Down"], bindings: $olsClues)

                    stat("OLS", "\(totalOLS)/4")
                }

                section("Notes") {
                    StyledTextEditor(text: $officerNotes)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showImpliedConsent) {
            IndianaImpliedConsentView()
        }
    }

    // MARK: - Helpers

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).foregroundColor(.white).bold()
            content()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    private func toggleList(_ titles: [String], bindings: Binding<[Bool]>) -> some View {
        VStack {
            ForEach(titles.indices, id: \.self) { i in
                Toggle(titles[i], isOn: bindings[i])
                    .tint(.blue)
                    .foregroundColor(.white)
            }
        }
    }

    private func instructionCard(_ lines: [String]) -> some View {
        VStack(alignment: .leading) {
            ForEach(lines, id: \.self) { line in
                Text("• \(line)").foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.15))
        .cornerRadius(12)
    }

    private func stat(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value).foregroundColor(.white).bold()
        }
    }

    private var totalHGN: Int { hgnLeft.filter{$0}.count + hgnRight.filter{$0}.count }
    private var totalWAT: Int { watClues.filter{$0}.count }
    private var totalOLS: Int { olsClues.filter{$0}.count }
}

struct IndianaImpliedConsentView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("""
Indiana Implied Consent Advisory:

I have probable cause to believe you operated a vehicle while intoxicated.

You are now requested to submit to a chemical test.

Refusal to submit to this test will result in the suspension of your driving privileges for at least one year.

Refusal may also be used as evidence against you in court.

Will you submit to the chemical test?
""")
                .foregroundColor(.white)
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Implied Consent")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}
