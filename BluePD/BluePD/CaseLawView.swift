import SwiftUI

struct CaseLawUpdate: Identifiable, Codable {
    let id: String
    let title: String
    let date: String
    let category: String
    let summary: String
    let impact: String
}

@MainActor
final class CaseLawViewModel: ObservableObject {
    @Published var updates: [CaseLawUpdate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let caseLawURL = URL(string: "https://raw.githubusercontent.com/geomods2017-dev/BluePD/main/BluePD/BluePD/caselaw.json")!

    func fetchCaseLaw() async {
        isLoading = true
        errorMessage = nil

        do {
            let (data, response) = try await URLSession.shared.data(from: caseLawURL)

            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            let decoded = try decoder.decode([CaseLawUpdate].self, from: data)

            updates = decoded.sorted { $0.date > $1.date }
            saveToCache(data)
        } catch {
            errorMessage = "Unable to load case law updates."
            loadFromCache()
        }

        isLoading = false
    }

    private func saveToCache(_ data: Data) {
        UserDefaults.standard.set(data, forKey: "cachedCaseLawData")
    }

    private func loadFromCache() {
        guard let cachedData = UserDefaults.standard.data(forKey: "cachedCaseLawData") else {
            return
        }

        do {
            let decoded = try JSONDecoder().decode([CaseLawUpdate].self, from: cachedData)
            updates = decoded.sorted { $0.date > $1.date }
        } catch {
            errorMessage = "No cached case law data available."
        }
    }
}

struct CaseLawView: View {
    @StateObject private var viewModel = CaseLawViewModel()
    @State private var searchText = ""

    private var filteredUpdates: [CaseLawUpdate] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return viewModel.updates
        }

        return viewModel.updates.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.category.localizedCaseInsensitiveContains(trimmed) ||
            $0.summary.localizedCaseInsensitiveContains(trimmed) ||
            $0.impact.localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var groupedUpdates: [String: [CaseLawUpdate]] {
        Dictionary(grouping: filteredUpdates, by: { $0.category })
    }

    private var sortedCategories: [String] {
        groupedUpdates.keys.sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            Group {
                if viewModel.isLoading && viewModel.updates.isEmpty {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage, viewModel.updates.isEmpty {
                    errorView(message: errorMessage)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 18) {
                            if !viewModel.updates.isEmpty {
                                infoBanner
                            }

                            if filteredUpdates.isEmpty {
                                emptySearchView
                            } else {
                                ForEach(sortedCategories, id: \.self) { category in
                                    categorySection(category: category, updates: groupedUpdates[category] ?? [])
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await viewModel.fetchCaseLaw()
                    }
                }
            }
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Case Law")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.updates.isEmpty {
                await viewModel.fetchCaseLaw()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.fetchCaseLaw()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 7/255, green: 12/255, blue: 24/255),
                Color(red: 13/255, green: 23/255, blue: 40/255),
                Color(red: 18/255, green: 29/255, blue: 48/255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Case Law Updates")
                .font(.headline)
                .foregroundColor(.white)

            Text("Search updates by title, category, summary, or officer impact.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.66))

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.50))

                TextField("Search case law", text: $searchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .foregroundColor(.white)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.42))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }

    private var infoBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.blue)

            Text("Case law feed updates weekly.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.78))

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.blue)

            Text("Loading case law...")
                .font(.headline)
                .foregroundColor(.white)

            Text("Checking for the latest available updates.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.62))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text(message)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.fetchCaseLaw()
                }
            } label: {
                Text("Retry")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.blue)
                    )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptySearchView: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundColor(.white.opacity(0.60))

            Text("No case law found")
                .font(.headline)
                .foregroundColor(.white)

            Text("Try a different title, category, or keyword.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.62))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func categorySection(category: String, updates: [CaseLawUpdate]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 2)

            VStack(spacing: 10) {
                ForEach(updates) { update in
                    NavigationLink(destination: CaseLawDetailView(update: update)) {
                        CaseLawRowCard(update: update)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct CaseLawRowCard: View {
    let update: CaseLawUpdate

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Text(update.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.32))
                    .padding(.top, 3)
            }

            HStack(spacing: 8) {
                Label(update.date, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.56))

                Spacer()

                Text(update.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
            }

            Text(update.summary)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.68))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct CaseLawDetailView: View {
    let update: CaseLawUpdate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(update.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(update.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.14))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())

                    Spacer()

                    Label(update.date, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.60))
                }

                detailSection(
                    title: "Summary",
                    bodyText: update.summary
                )

                detailSection(
                    title: "Officer Impact",
                    bodyText: update.impact
                )
            }
            .padding(16)
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
        .navigationTitle("Case Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailSection(title: String, bodyText: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(bodyText)
                .font(.body)
                .foregroundColor(.white.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        CaseLawView()
    }
}
