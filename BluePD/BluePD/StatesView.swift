import SwiftUI

struct StatesView: View {
    private let states: [StateCodeEntry] = [
        StateCodeEntry(
            stateName: "Indiana",
            categories: [
                StateCodeCategory(
                    name: "Traffic Code",
                    statutes: [
                        StateStatute(
                            title: "Speeding",
                            statuteNumber: "IC 9-21-5-1",
                            description: "A person may not drive a vehicle on a highway at a speed greater than is reasonable and prudent under the conditions.",
                            notes: "Use posted limits, roadway conditions, and officer observations."
                        ),
                        StateStatute(
                            title: "Reckless Driving",
                            statuteNumber: "IC 9-21-8-52",
                            description: "A person who drives at an unreasonably high or low speed so as to endanger safety or block traffic may commit reckless driving.",
                            notes: "Document specific driving behavior, traffic conditions, and risk created."
                        ),
                        StateStatute(
                            title: "Driving While Suspended",
                            statuteNumber: "IC 9-24-19-2",
                            description: "Operating a motor vehicle while driving privileges are suspended can constitute an offense.",
                            notes: "Confirm status through valid records check."
                        )
                    ]
                ),
                StateCodeCategory(
                    name: "Criminal Code",
                    statutes: [
                        StateStatute(
                            title: "Resisting Law Enforcement",
                            statuteNumber: "IC 35-44.1-3-1",
                            description: "A person who forcibly resists, obstructs, or interferes with law enforcement may commit resisting law enforcement.",
                            notes: "Clearly describe force, refusal, flight, or interference."
                        ),
                        StateStatute(
                            title: "Battery",
                            statuteNumber: "IC 35-42-2-1",
                            description: "Knowingly or intentionally touching another person in a rude, insolent, or angry manner may constitute battery.",
                            notes: "Document injury, contact, statements, and witness observations."
                        )
                    ]
                ),
                StateCodeCategory(
                    name: "OWI / DUI",
                    statutes: [
                        StateStatute(
                            title: "Operating While Intoxicated",
                            statuteNumber: "IC 9-30-5-2",
                            description: "A person who operates a vehicle while intoxicated commits an offense.",
                            notes: "Document impairment indicators, driving behavior, SFSTs, admissions, and chemical test status."
                        )
                    ]
                )
            ]
        ),

        StateCodeEntry(stateName: "Illinois", categories: []),
        StateCodeEntry(stateName: "Kentucky", categories: []),
        StateCodeEntry(stateName: "Ohio", categories: []),
        StateCodeEntry(stateName: "Michigan", categories: []),
        StateCodeEntry(stateName: "Florida", categories: []),
        StateCodeEntry(stateName: "Texas", categories: []),
        StateCodeEntry(stateName: "California", categories: [])
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.03, green: 0.07, blue: 0.14)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "shield.lefthalf.filled")
                                    .foregroundColor(.blue)

                                Text("BLUE PD")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue.opacity(0.9))
                                    .tracking(2)
                            }

                            Text("State Codes")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)

                            Text("Browse statutes by state and category")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.72))
                        }

                        VStack(spacing: 12) {
                            ForEach(states) { state in
                                NavigationLink(destination: StateCategoryView(state: state)) {
                                    PoliceStateRow(title: state.stateName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PoliceStateRow: View {
    let title: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("View statute categories")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.blue.opacity(0.85))
                .font(.headline)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.blue.opacity(0.28), lineWidth: 1)
                )
        )
    }
}
