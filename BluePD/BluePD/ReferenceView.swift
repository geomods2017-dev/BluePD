import SwiftUI
import SafariServices

/// Replaces the old "Case Law" tab (which just opened findlaw.com in a browser) and the old
/// "Codes" tab (a bare list of links to state legislature sites) with one Reference tab that
/// actually earns its place: your own state pinned up top, a short list of doctrine that's
/// settled enough not to go stale, and the full state-code directory as a fallback lookup.
///
/// Deliberately does NOT include "recent rulings" or anything time-sensitive — the app
/// previously shipped an unused `caselaw.json` with a few plausible-looking but unsourced
/// "recent" court decisions. Presenting invented or unverifiable case law as authoritative
/// is a real liability risk for the officers using this, so this screen only carries doctrine
/// that is decades-settled and widely taught, with an explicit disclaimer, plus links out to
/// official sources for anything current.
struct ReferenceView: View {
    @AppStorage("defaultState") private var defaultState: String = "Indiana"
    // Re-declaring this key (unused directly) makes SwiftUI re-render this screen whenever
    // Daylight Mode is toggled in Settings, since BluePDTheme reads it live.
    @AppStorage(BluePDTheme.daylightModeKey) private var daylightModeEnabled: Bool = false

    @State private var searchText = ""
    @State private var selectedURL: IdentifiableURL?

    private let states: [StateLink] = ReferenceView.allStates

    private var pinnedState: StateLink? {
        states.first { $0.name.localizedCaseInsensitiveCompare(defaultState) == .orderedSame }
    }

    private var filteredStates: [StateLink] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let sorted = states.sorted { $0.name < $1.name }

        guard !trimmed.isEmpty else { return sorted }

        return sorted.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed) ||
            $0.abbreviation.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerCard
                    disclaimerBanner

                    if let pinnedState {
                        pinnedStateSection(pinnedState)
                    }

                    doctrineSection
                    stateDirectorySection
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
            .background(BluePDTheme.appBackground.ignoresSafeArea())
            .navigationTitle("Reference")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedURL) { item in
                SafariView(url: item.url)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reference")
                .font(.title2.weight(.bold))
                .foregroundStyle(BluePDTheme.primaryText)

            Text("Your state's codes, foundational case law, and the full state directory.")
                .font(.subheadline)
                .foregroundStyle(BluePDTheme.secondaryText)
        }
        .padding(20)
        .bluePDCard(cornerRadius: 24)
    }

    private var disclaimerBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(BluePDTheme.warning)

            Text("General awareness only — not legal advice. Confirm current status and applicability with your agency's legal advisor before relying on this in the field.")
                .font(.caption)
                .foregroundStyle(BluePDTheme.secondaryText)
        }
        .padding(14)
        .bluePDInnerCard(cornerRadius: 16)
    }

    private func pinnedStateSection(_ state: StateLink) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Your State")

            Button {
                if let url = state.url {
                    selectedURL = IdentifiableURL(url: url)
                }
            } label: {
                StateRowCard(state: state, isPinned: true)
            }
            .buttonStyle(.plain)
        }
    }

    private var doctrineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Foundational Case Law")

            VStack(spacing: 12) {
                ForEach(ReferenceView.doctrineCases) { item in
                    DoctrineCard(item: item)
                }
            }
        }
    }

    private var stateDirectorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Full State Code Lookup")

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(BluePDTheme.secondaryText)

                TextField(
                    "",
                    text: $searchText,
                    prompt: Text("Search state or abbreviation")
                        .foregroundColor(BluePDTheme.placeholderText)
                )
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .foregroundStyle(BluePDTheme.primaryText)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(BluePDTheme.tertiaryText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: BluePDTheme.controlHeight)
            .bluePDInnerCard(cornerRadius: 18)

            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && filteredStates.isEmpty {
                BluePDEmptyState(
                    systemImage: "magnifyingglass",
                    title: "No States Found",
                    message: "Try searching by full state name or abbreviation."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredStates) { state in
                        Button {
                            if let url = state.url {
                                selectedURL = IdentifiableURL(url: url)
                            }
                        } label: {
                            StateRowCard(state: state, isPinned: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(BluePDTheme.accent)
                .frame(width: 5, height: 24)

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(BluePDTheme.primaryText)

            Spacer()
        }
        .padding(.horizontal, 2)
    }
}

// MARK: - Foundational doctrine

/// Real, decades-settled, widely-taught holdings — not "recent rulings," which would go
/// stale and can't responsibly be maintained inside an app binary. Paraphrased summaries,
/// not verbatim opinion text.
struct DoctrineCase: Identifiable {
    let id = UUID()
    let name: String
    let citation: String
    let year: String
    let summary: String
}

extension ReferenceView {
    static let doctrineCases: [DoctrineCase] = [
        DoctrineCase(
            name: "Terry v. Ohio",
            citation: "392 U.S. 1",
            year: "1968",
            summary: "An officer may briefly stop and pat down a person for weapons based on reasonable, articulable suspicion of criminal activity and a reasonable belief the person may be armed — a lower bar than probable cause, but it still requires specific, articulable facts, not a hunch."
        ),
        DoctrineCase(
            name: "Miranda v. Arizona",
            citation: "384 U.S. 436",
            year: "1966",
            summary: "Before custodial interrogation, a suspect must be advised of the right to remain silent and the right to counsel. Statements obtained in violation generally can't be used in the prosecution's case-in-chief. Applies to custodial interrogation specifically, not every police contact."
        ),
        DoctrineCase(
            name: "Graham v. Connor",
            citation: "490 U.S. 386",
            year: "1989",
            summary: "Claims that an officer used excessive force are judged under the Fourth Amendment's 'objective reasonableness' standard — from the perspective of a reasonable officer on scene, given the facts known at the time, not with 20/20 hindsight."
        ),
        DoctrineCase(
            name: "Illinois v. Wardlow",
            citation: "528 U.S. 119",
            year: "2000",
            summary: "Unprovoked flight upon noticing police, in a high-crime area, can factor into reasonable suspicion supporting a Terry stop — though presence in a high-crime area alone is not enough by itself."
        ),
        DoctrineCase(
            name: "Rodriguez v. United States",
            citation: "575 U.S. 348",
            year: "2015",
            summary: "A traffic stop can't be extended beyond the time reasonably required to complete its original purpose (and related safety checks) to conduct unrelated investigation, such as a K-9 sniff, absent independent reasonable suspicion."
        )
    ]
}

struct DoctrineCard: View {
    let item: DoctrineCase

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Spacer()

                Text(item.year)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BluePDTheme.tertiaryText)
            }

            Text(item.citation)
                .font(.caption.weight(.medium))
                .foregroundStyle(BluePDTheme.accent)

            Text(item.summary)
                .font(.subheadline)
                .foregroundStyle(BluePDTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 20)
    }
}

// MARK: - State directory (unchanged list, relocated from the old StatesView)

struct StateRowCard: View {
    let state: StateLink
    var isPinned: Bool

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 3) {
                Text(state.abbreviation)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BluePDTheme.accent)

                if isPinned {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(BluePDTheme.accent.opacity(0.92))
                }
            }
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(BluePDTheme.accent.opacity(isPinned ? 0.14 : 0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(BluePDTheme.accent.opacity(isPinned ? 0.26 : 0.18), lineWidth: 1)
                    )
            )

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(state.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(BluePDTheme.primaryText)

                    if isPinned {
                        Text("Pinned")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(BluePDTheme.accent.opacity(0.12))
                            .foregroundStyle(BluePDTheme.accent)
                            .clipShape(Capsule())
                    }
                }

                Text("Official state code access")
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "arrow.up.right.square")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BluePDTheme.tertiaryText)
        }
        .padding(16)
        .bluePDInnerCard(cornerRadius: 22)
    }
}

struct StateLink: Identifiable {
    let id = UUID()
    let name: String
    let abbreviation: String
    let urlString: String

    var url: URL? {
        URL(string: urlString)
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UIColor.systemBlue
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

extension ReferenceView {
    static let allStates: [StateLink] = [
        StateLink(name: "Alabama", abbreviation: "AL", urlString: "https://alison.legislature.state.al.us/code-of-alabama"),
        StateLink(name: "Alaska", abbreviation: "AK", urlString: "https://www.akleg.gov/basis/statutes.asp"),
        StateLink(name: "Arizona", abbreviation: "AZ", urlString: "https://www.azleg.gov/arstitle"),
        StateLink(name: "Arkansas", abbreviation: "AR", urlString: "https://www.arkleg.state.ar.us/ArkansasLaw"),
        StateLink(name: "California", abbreviation: "CA", urlString: "https://leginfo.legislature.ca.gov/faces/codes.xhtml"),
        StateLink(name: "Colorado", abbreviation: "CO", urlString: "https://leg.colorado.gov/agencies/office-legislative-legal-services/colorado-revised-statutes"),
        StateLink(name: "Connecticut", abbreviation: "CT", urlString: "https://www.cga.ct.gov/current/pub/titles.htm"),
        StateLink(name: "Delaware", abbreviation: "DE", urlString: "https://delcode.delaware.gov"),
        StateLink(name: "Florida", abbreviation: "FL", urlString: "http://www.leg.state.fl.us/statutes"),
        StateLink(name: "Georgia", abbreviation: "GA", urlString: "https://legis.ga.gov/"),
        StateLink(name: "Hawaii", abbreviation: "HI", urlString: "https://www.capitol.hawaii.gov/hrscurrent"),
        StateLink(name: "Idaho", abbreviation: "ID", urlString: "https://legislature.idaho.gov/statutesrules/idstat"),
        StateLink(name: "Illinois", abbreviation: "IL", urlString: "https://www.ilga.gov/legislation/ilcs/ilcs.asp"),
        StateLink(name: "Indiana", abbreviation: "IN", urlString: "https://iga.in.gov/laws/2025/ic/titles/1"),
        StateLink(name: "Iowa", abbreviation: "IA", urlString: "https://www.legis.iowa.gov/law/iowaCode"),
        StateLink(name: "Kansas", abbreviation: "KS", urlString: "https://www.kslegislature.org/li/b2025_26/statute"),
        StateLink(name: "Kentucky", abbreviation: "KY", urlString: "https://apps.legislature.ky.gov/law/statutes"),
        StateLink(name: "Louisiana", abbreviation: "LA", urlString: "https://www.legis.la.gov/legis/Laws_Toc.aspx"),
        StateLink(name: "Maine", abbreviation: "ME", urlString: "https://legislature.maine.gov/statutes"),
        StateLink(name: "Maryland", abbreviation: "MD", urlString: "https://mgaleg.maryland.gov/mgawebsite/Laws/StatuteText"),
        StateLink(name: "Massachusetts", abbreviation: "MA", urlString: "https://malegislature.gov/Laws/GeneralLaws"),
        StateLink(name: "Michigan", abbreviation: "MI", urlString: "https://www.legislature.mi.gov/Laws/MCL"),
        StateLink(name: "Minnesota", abbreviation: "MN", urlString: "https://www.revisor.mn.gov/statutes"),
        StateLink(name: "Mississippi", abbreviation: "MS", urlString: "https://www.legislature.ms.gov/"),
        StateLink(name: "Missouri", abbreviation: "MO", urlString: "https://revisor.mo.gov/main/Home.aspx"),
        StateLink(name: "Montana", abbreviation: "MT", urlString: "https://leg.mt.gov/bills/mca/title_index.html"),
        StateLink(name: "Nebraska", abbreviation: "NE", urlString: "https://nebraskalegislature.gov/laws/statutes.php"),
        StateLink(name: "Nevada", abbreviation: "NV", urlString: "https://www.leg.state.nv.us/NRS"),
        StateLink(name: "New Hampshire", abbreviation: "NH", urlString: "https://www.gencourt.state.nh.us/rsa/html/indexes"),
        StateLink(name: "New Jersey", abbreviation: "NJ", urlString: "https://www.njleg.state.nj.us/"),
        StateLink(name: "New Mexico", abbreviation: "NM", urlString: "https://nmonesource.com/nmos/nmsa/en/nav_date.do"),
        StateLink(name: "New York", abbreviation: "NY", urlString: "https://www.nysenate.gov/legislation/laws"),
        StateLink(name: "North Carolina", abbreviation: "NC", urlString: "https://www.ncleg.gov/Laws/GeneralStatutesTOC"),
        StateLink(name: "North Dakota", abbreviation: "ND", urlString: "https://www.ndlegis.gov/general-information/north-dakota-century-code"),
        StateLink(name: "Ohio", abbreviation: "OH", urlString: "https://codes.ohio.gov/ohio-revised-code"),
        StateLink(name: "Oklahoma", abbreviation: "OK", urlString: "https://www.oscn.net/applications/oscn/index.asp?level=1&ftdb=STOKST"),
        StateLink(name: "Oregon", abbreviation: "OR", urlString: "https://www.oregonlegislature.gov/bills_laws/ors/ors.html"),
        StateLink(name: "Pennsylvania", abbreviation: "PA", urlString: "https://www.legis.state.pa.us/cfdocs/legis/LI/Public/cons_index.cfm"),
        StateLink(name: "Rhode Island", abbreviation: "RI", urlString: "https://webserver.rilegislature.gov/Statutes"),
        StateLink(name: "South Carolina", abbreviation: "SC", urlString: "https://www.scstatehouse.gov/code/statmast.php"),
        StateLink(name: "South Dakota", abbreviation: "SD", urlString: "https://sdlegislature.gov/Statutes"),
        StateLink(name: "Tennessee", abbreviation: "TN", urlString: "https://capitol.tn.gov/"),
        StateLink(name: "Texas", abbreviation: "TX", urlString: "https://statutes.capitol.texas.gov"),
        StateLink(name: "Utah", abbreviation: "UT", urlString: "https://le.utah.gov/xcode/code.html"),
        StateLink(name: "Vermont", abbreviation: "VT", urlString: "https://legislature.vermont.gov/statutes"),
        StateLink(name: "Virginia", abbreviation: "VA", urlString: "https://law.lis.virginia.gov/vacode"),
        StateLink(name: "Washington", abbreviation: "WA", urlString: "https://app.leg.wa.gov/rcw"),
        StateLink(name: "West Virginia", abbreviation: "WV", urlString: "https://code.wvlegislature.gov"),
        StateLink(name: "Wisconsin", abbreviation: "WI", urlString: "https://docs.legis.wisconsin.gov/statutes/statutes"),
        StateLink(name: "Wyoming", abbreviation: "WY", urlString: "https://wyoleg.gov/Legislation/Statutes")
    ]
}

#Preview {
    ReferenceView()
}
