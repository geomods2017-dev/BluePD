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

    // Replace this with your real hosted JSON URL
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

            // Sort newest first by date string
            updates = decoded.sorted {
                $0.date > $1.date
            }

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
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.updates
        }

        return viewModel.updates.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText) ||
            $0.summary.localizedCaseInsensitiveContains(searchText) ||
            $0.impact.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedUpdates: [String: [CaseLawUpdate]] {
        Dictionary(grouping: filteredUpdates, by: { $0.category })
    }

    private var sortedCategories: [String] {
        groupedUpdates.keys.sorted()
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.updates.isEmpty {
                    ProgressView("Loading Case Law...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.updates.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 42))
                            .foregroundColor(.orange)

                        Text(errorMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task {
                                await viewModel.fetchCaseLaw()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if !viewModel.updates.isEmpty {
                            Section {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                    Text("Updated Weekly")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        ForEach(sortedCategories, id: \.self) { category in
                            Section(category) {
                                ForEach(groupedUpdates[category] ?? []) { update in
                                    NavigationLink(destination: CaseLawDetailView(update: update)) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(update.title)
                                                .font(.headline)

                                            Text(update.date)
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            Text(update.summary)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        await viewModel.fetchCaseLaw()
                    }
                    .searchable(text: $searchText, prompt: "Search case law")
                }
            }
            .navigationTitle("Case Law")
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
                    }
                }
            }
        }
    }
}

struct CaseLawDetailView: View {
    let update: CaseLawUpdate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(update.title)
                    .font(.title2)
                    .bold()

                HStack {
                    Label(update.category, systemImage: "folder")
                    Spacer()
                    Label(update.date, systemImage: "calendar")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.headline)

                    Text(update.summary)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Officer Impact")
                        .font(.headline)

                    Text(update.impact)
                        .font(.body)
                }
            }
            .padding()
        }
        .navigationTitle("Case Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CaseLawView()
}
