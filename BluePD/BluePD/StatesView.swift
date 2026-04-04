import SwiftUI
import SafariServices

struct StatesView: View {
    @State private var searchText = ""
    @State private var selectedURL: IdentifiableURL?

    private let states: [StateLink] = [
        StateLink(name: "Indiana", abbreviation: "IN", urlString: "https://iga.in.gov/laws/2025/ic/titles/1", isPinned: true),

        StateLink(name: "Alabama", abbreviation: "AL", urlString: "https://alisondb.legislature.state.al.us"),
        StateLink(name: "Alaska", abbreviation: "AK", urlString: "https://www.akleg.gov/basis/statutes.asp"),
        StateLink(name: "Arizona", abbreviation: "AZ", urlString: "https://www.azleg.gov/arstitle"),
        StateLink(name: "Arkansas", abbreviation: "AR", urlString: "https://www.arkleg.state.ar.us/ArkansasCode/Index"),
        StateLink(name: "California", abbreviation: "CA", urlString: "https://leginfo.legislature.ca.gov/faces/codes.xhtml"),
        StateLink(name: "Colorado", abbreviation: "CO", urlString: "https://leg.colorado.gov/agencies/office-legislative-legal-services/colorado-revised-statutes"),
        StateLink(name: "Connecticut", abbreviation: "CT", urlString: "https://www.cga.ct.gov/current/pub/titles.htm"),
        StateLink(name: "Delaware", abbreviation: "DE", urlString: "https://delcode.delaware.gov"),
        StateLink(name: "Florida", abbreviation: "FL", urlString: "http://www.leg.state.fl.us/statutes"),
        StateLink(name: "Georgia", abbreviation: "GA", urlString: "https://law.justia.com/codes/georgia"),
        StateLink(name: "Hawaii", abbreviation: "HI", urlString: "https://www.capitol.hawaii.gov/hrscurrent"),
        StateLink(name: "Idaho", abbreviation: "ID", urlString: "https://legislature.idaho.gov/statutesrules/idstat"),
        StateLink(name: "Illinois", abbreviation: "IL", urlString: "https://www.ilga.gov/legislation/ilcs/ilcs.asp"),
        StateLink(name: "Iowa", abbreviation: "IA", urlString: "https://www.legis.iowa.gov/law/iowaCode"),
        StateLink(name: "Kansas", abbreviation: "KS", urlString: "https://www.kslegislature.org/li/b2025_26/statute"),
        StateLink(name: "Kentucky", abbreviation: "KY", urlString: "https://apps.legislature.ky.gov/law/statutes"),
        StateLink(name: "Louisiana", abbreviation: "LA", urlString: "https://www.legis.la.gov/legis/Laws_Toc.aspx"),
        StateLink(name: "Maine", abbreviation: "ME", urlString: "https://legislature.maine.gov/statutes"),
        StateLink(name: "Maryland", abbreviation: "MD", urlString: "https://mgaleg.maryland.gov/mgawebsite/Laws/StatuteText"),
        StateLink(name: "Massachusetts", abbreviation: "MA", urlString: "https://malegislature.gov/Laws/GeneralLaws"),
        StateLink(name: "Michigan", abbreviation: "MI", urlString: "https://www.legislature.mi.gov/Laws/MCL"),
        StateLink(name: "Minnesota", abbreviation: "MN", urlString: "https://www.revisor.mn.gov/statutes"),
        StateLink(name: "Mississippi", abbreviation: "MS", urlString: "https://advance.lexis.com/container?config=00JAA1MDBlZmQ0Yi1lODNhLTQ0OWQtYTU0Yi0zZjdiNTQ0MDRhYmMKAFBvZENhdGFsb2f6Wl0lru6x0n3bJt1Y&crid=ca419408-8546-4d73-b7b3-582106621fca"),
        StateLink(name: "Missouri", abbreviation: "MO", urlString: "https://revisor.mo.gov/main/Home.aspx"),
        StateLink(name: "Montana", abbreviation: "MT", urlString: "https://leg.mt.gov/bills/mca/title_index.html"),
        StateLink(name: "Nebraska", abbreviation: "NE", urlString: "https://nebraskalegislature.gov/laws/statutes.php"),
        StateLink(name: "Nevada", abbreviation: "NV", urlString: "https://www.leg.state.nv.us/NRS"),
        StateLink(name: "New Hampshire", abbreviation: "NH", urlString: "https://www.gencourt.state.nh.us/rsa/html/indexes"),
        StateLink(name: "New Jersey", abbreviation: "NJ", urlString: "https://www.njleg.state.nj.us/laws-statutory"),
        StateLink(name: "New Mexico", abbreviation: "NM", urlString: "https://nmonesource.com/nmos/nmsa/en/nav_date.do"),
        StateLink(name: "New York", abbreviation: "NY", urlString: "https://www.nysenate.gov/legislation/laws"),
        StateLink(name: "North Carolina", abbreviation: "NC", urlString: "https://www.ncleg.gov/Laws/GeneralStatutesTOC"),
        StateLink(name: "North Dakota", abbreviation: "ND", urlString: "https://www.ndlegis.gov/general-information/north-dakota-century-code"),
        StateLink(name: "Ohio", abbreviation: "OH", urlString: "https://codes.ohio.gov/ohio-revised-code"),
        StateLink(name: "Oklahoma", abbreviation: "OK", urlString: "https://oksenate.gov/legislation/oklahoma_statutes.aspx"),
        StateLink(name: "Oregon", abbreviation: "OR", urlString: "https://www.oregonlegislature.gov/bills_laws/ors/ors.html"),
        StateLink(name: "Pennsylvania", abbreviation: "PA", urlString: "https://www.legis.state.pa.us/cfdocs/legis/LI/Public/cons_index.cfm"),
        StateLink(name: "Rhode Island", abbreviation: "RI", urlString: "https://webserver.rilegislature.gov/Statutes"),
        StateLink(name: "South Carolina", abbreviation: "SC", urlString: "https://www.scstatehouse.gov/code/statmast.php"),
        StateLink(name: "South Dakota", abbreviation: "SD", urlString: "https://sdlegislature.gov/Statutes"),
        StateLink(name: "Tennessee", abbreviation: "TN", urlString: "https://advance.lexis.com/container?config=00JAA1OWQ5NzViZS0wMWM0LTRhZjAtYjQ3Yy1kYjY0MTQ4M2ZmYTYKAFBvZENhdGFsb2c5ci%2B8lY8iHUpmii4gON7F&crid=4e2f1d06-6db9-4cb0-9e5f-08ef2501c1ee"),
        StateLink(name: "Texas", abbreviation: "TX", urlString: "https://statutes.capitol.texas.gov"),
        StateLink(name: "Utah", abbreviation: "UT", urlString: "https://le.utah.gov/xcode/code.html"),
        StateLink(name: "Vermont", abbreviation: "VT", urlString: "https://legislature.vermont.gov/statutes"),
        StateLink(name: "Virginia", abbreviation: "VA", urlString: "https://law.lis.virginia.gov/vacode"),
        StateLink(name: "Washington", abbreviation: "WA", urlString: "https://app.leg.wa.gov/rcw"),
        StateLink(name: "West Virginia", abbreviation: "WV", urlString: "https://code.wvlegislature.gov"),
        StateLink(name: "Wisconsin", abbreviation: "WI", urlString: "https://docs.legis.wisconsin.gov/statutes/statutes"),
        StateLink(name: "Wyoming", abbreviation: "WY", urlString: "https://wyoleg.gov/Legislation/Statutes")
    ]

    private var filteredStates: [StateLink] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let sortedStates = states.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned && !rhs.isPinned
            }
            return lhs.name < rhs.name
        }

        guard !trimmed.isEmpty else { return sortedStates }

        return sortedStates.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed) ||
            $0.abbreviation.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && filteredStates.isEmpty {
                        emptyStateCard
                    } else {
                        ForEach(filteredStates) { state in
                            Button {
                                if let url = state.url {
                                    selectedURL = IdentifiableURL(url: url)
                                }
                            } label: {
                                StateRowCard(state: state)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
        }
        .background(BluePDTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Codes")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedURL) { item in
            SafariView(url: item.url)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Official State Code Links")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(BluePDTheme.primaryText)

                Text("Search by state name or abbreviation. Indiana stays pinned at the top.")
                    .font(.subheadline)
                    .foregroundStyle(BluePDTheme.secondaryText)
            }

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
            .frame(height: 58)
            .bluePDInnerCard(cornerRadius: 18)
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 14)
    }

    private var emptyStateCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(BluePDTheme.secondaryText)

            Text("No States Found")
                .font(.title3.weight(.semibold))
                .foregroundStyle(BluePDTheme.primaryText)

            Text("Try searching by full state name or abbreviation.")
                .font(.subheadline)
                .foregroundStyle(BluePDTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .bluePDCard(cornerRadius: 22)
    }
}

struct StateRowCard: View {
    let state: StateLink

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 3) {
                Text(state.abbreviation)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BluePDTheme.accent)

                if state.isPinned {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(BluePDTheme.accent.opacity(0.92))
                }
            }
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(state.isPinned ? BluePDTheme.accent.opacity(0.14) : BluePDTheme.accent.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(BluePDTheme.accent.opacity(state.isPinned ? 0.26 : 0.18), lineWidth: 1)
                    )
            )

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(state.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(BluePDTheme.primaryText)

                    if state.isPinned {
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
    let isPinned: Bool

    var url: URL? {
        URL(string: urlString)
    }

    init(name: String, abbreviation: String, urlString: String, isPinned: Bool = false) {
        self.name = name
        self.abbreviation = abbreviation
        self.urlString = urlString
        self.isPinned = isPinned
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
