import SwiftUI

struct QuickReferenceCard: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
}

enum QuickCardStorage {
    private static let filename = "quick_cards.json"

    static func url() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    static func save(_ cards: [QuickReferenceCard]) {
        guard let data = try? JSONEncoder().encode(cards) else { return }
        try? data.write(to: url())
    }

    static func load() -> [QuickReferenceCard] {
        guard let data = try? Data(contentsOf: url()),
              let cards = try? JSONDecoder().decode([QuickReferenceCard].self, from: data) else {
            return []
        }
        return cards.sorted { $0.createdAt > $1.createdAt }
    }
}

struct QuickCardsView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var cloudSync: CloudSyncManager

    // Re-declaring this key (unused directly) makes SwiftUI re-render this screen
    // whenever Daylight Mode is toggled in Settings, since BluePDTheme reads it live.
    @AppStorage(BluePDTheme.daylightModeKey) private var daylightModeEnabled: Bool = false

    @State private var cards: [QuickReferenceCard] = []
    @State private var searchText = ""
    @State private var selectedCard: QuickReferenceCard?
    @State private var showCreateCard = false
    @State private var showUpgradeAlert = false
    @State private var isPurchasingPro = false
    @State private var statusMessage = ""
    @State private var hasRunInitialSync = false

    private let freeCardLimit = 3

    private var hasReachedFreeCardLimit: Bool {
        !storeManager.isPro && cards.count >= freeCardLimit
    }

    private var filteredCards: [QuickReferenceCard] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearch.isEmpty else { return cards }

        return cards.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedSearch) ||
            $0.content.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BluePDTheme.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    headerSection
                    storageBanner
                    searchSection

                    if filteredCards.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCards) { card in
                                    Button {
                                        selectedCard = card
                                    } label: {
                                        quickCardRow(card)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button {
                                            selectedCard = card
                                        } label: {
                                            Label("Open", systemImage: "eye.fill")
                                        }

                                        Button(role: .destructive) {
                                            deleteCard(card)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .navigationTitle("Quick Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createCardTapped()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(BluePDTheme.primaryText)
                    }
                }
            }
            .onAppear {
                loadCards()
            }
            .task {
                guard !hasRunInitialSync else { return }
                hasRunInitialSync = true
                await runInitialSync()
            }
            .sheet(isPresented: $showCreateCard) {
                CreateQuickCardView { newCard in
                    cards.insert(newCard, at: 0)
                    QuickCardStorage.save(cards)
                    statusMessage = "Quick card saved."
                    Task { await cloudSync.push(newCard, id: newCard.id, kind: .card, updatedAt: newCard.createdAt) }
                }
            }
            .sheet(item: $selectedCard) { card in
                QuickCardDetailView(
                    card: card,
                    onSave: { updatedCard in
                        updateCard(updatedCard)
                    },
                    onDelete: {
                        deleteCard(card)
                        selectedCard = nil
                    }
                )
            }
            .alert("Upgrade to BluePD Pro", isPresented: $showUpgradeAlert) {
                Button(isPurchasingPro ? "Purchasing..." : "Upgrade") {
                    purchasePro()
                }
                .disabled(isPurchasingPro)

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Free users can create up to \(freeCardLimit) custom Quick Cards. Upgrade to BluePD Pro for unlimited cards.")
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                BluePDIconContainer(systemImage: "rectangle.stack.text.card.fill", size: 44, iconSize: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Reference Cards")
                        .font(.title3.weight(.bold))
                        .foregroundColor(BluePDTheme.primaryText)

                    Text("Create personalized quick-access field notes")
                        .font(.subheadline)
                        .foregroundColor(BluePDTheme.secondaryText)
                }

                Spacer()
            }

            Text("Store your own reminders, statutes, notes, procedures, or checklists for fast access.")
                .font(.subheadline)
                .foregroundColor(BluePDTheme.secondaryText)
        }
        .padding(16)
        .bluePDCard(cornerRadius: 18)
        .padding(.horizontal, 16)
    }

    private var storageBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: storeManager.isPro ? "checkmark.seal.fill" : "rectangle.stack.fill")
                    .foregroundColor(storeManager.isPro ? BluePDTheme.success : BluePDTheme.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(storeManager.isPro ? "BluePD Pro Active" : "Free Quick Cards")
                        .font(.headline)
                        .foregroundColor(BluePDTheme.primaryText)

                    Text(storeManager.isPro ? "Unlimited custom cards available" : "\(cards.count)/\(freeCardLimit) cards used")
                        .font(.caption)
                        .foregroundColor(BluePDTheme.secondaryText)
                }

                Spacer()
            }

            if hasReachedFreeCardLimit {
                Text("Free card limit reached. Upgrade to BluePD Pro for unlimited custom cards.")
                    .font(.caption)
                    .foregroundColor(BluePDTheme.warning)
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(BluePDTheme.secondaryText)
            }
        }
        .padding(14)
        .bluePDInnerCard(cornerRadius: 14)
        .padding(.horizontal, 16)
    }

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(BluePDTheme.tertiaryText)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search quick cards").foregroundColor(BluePDTheme.placeholderText)
            )
            .foregroundColor(BluePDTheme.primaryText)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.sentences)
        }
        .padding(14)
        .bluePDInnerCard(cornerRadius: 14)
        .padding(.horizontal, 16)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Spacer()

            BluePDEmptyState(
                systemImage: "rectangle.stack.text.card",
                title: searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No Quick Cards Yet" : "No Matching Cards",
                message: searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? "Create a custom quick card to store notes, procedures, or reminders."
                    : "Try a different search term."
            )
            .padding(.horizontal, 16)

            Button {
                createCardTapped()
            } label: {
                Text("Create Quick Card")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BluePDPrimaryButtonStyle())
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func quickCardRow(_ card: QuickReferenceCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(card.title)
                    .font(.headline)
                    .foregroundColor(BluePDTheme.primaryText)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BluePDTheme.tertiaryText)
            }

            Text(card.content)
                .font(.subheadline)
                .foregroundColor(BluePDTheme.secondaryText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Text(card.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(BluePDTheme.tertiaryText)
        }
        .padding(14)
        .bluePDInnerCard(cornerRadius: 14)
    }

    private func createCardTapped() {
        statusMessage = ""

        if hasReachedFreeCardLimit {
            showUpgradeAlert = true
        } else {
            showCreateCard = true
        }
    }

    private func loadCards() {
        cards = QuickCardStorage.load()
    }

    private func updateCard(_ updatedCard: QuickReferenceCard) {
        guard let index = cards.firstIndex(where: { $0.id == updatedCard.id }) else { return }
        cards[index] = updatedCard
        cards.sort { $0.createdAt > $1.createdAt }
        QuickCardStorage.save(cards)
        statusMessage = "Quick card updated."
        Task { await cloudSync.push(updatedCard, id: updatedCard.id, kind: .card, updatedAt: Date()) }
    }

    private func deleteCard(_ card: QuickReferenceCard) {
        cards.removeAll { $0.id == card.id }
        QuickCardStorage.save(cards)
        statusMessage = "Quick card deleted."
        Task { await cloudSync.delete(id: card.id, kind: .card) }
    }

    private func purchasePro() {
        guard !isPurchasingPro else { return }

        isPurchasingPro = true
        statusMessage = "Contacting App Store..."

        Task {
            await storeManager.purchase()

            await MainActor.run {
                isPurchasingPro = false

                if storeManager.isPro {
                    statusMessage = "BluePD Pro unlocked. You now have unlimited Quick Cards."
                } else {
                    statusMessage = "Purchase not completed."
                }
            }
        }
    }

    @MainActor
    private func runInitialSync() async {
        await cloudSync.checkAccountStatus()
        guard cloudSync.status.isHealthy else { return }

        let remoteCards = await cloudSync.pullAll(kind: .card, as: QuickReferenceCard.self)
        let merged = CloudSyncManager.mergeAdditively(local: cards, remote: remoteCards)

        if merged.count != cards.count {
            cards = merged.sorted { $0.createdAt > $1.createdAt }
            QuickCardStorage.save(cards)
        }
    }
}

struct CreateQuickCardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""

    var onSave: (QuickReferenceCard) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                BluePDTheme.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundColor(BluePDTheme.secondaryText)

                        TextField("Enter card title", text: $title)
                            .foregroundColor(BluePDTheme.primaryText)
                            .padding()
                            .background(BluePDTheme.cardFill)
                            .cornerRadius(14)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.caption)
                            .foregroundColor(BluePDTheme.secondaryText)

                        TextEditor(text: $content)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(BluePDTheme.primaryText)
                            .frame(minHeight: 220)
                            .padding(10)
                            .background(BluePDTheme.cardFill)
                            .cornerRadius(14)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Quick Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(BluePDTheme.primaryText)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let newCard = QuickReferenceCard(
                            id: UUID(),
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                            createdAt: Date()
                        )
                        onSave(newCard)
                        dismiss()
                    }
                    .foregroundColor(BluePDTheme.primaryText)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct QuickCardDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var content: String
    @State private var shareFile: ShareableFile?

    let card: QuickReferenceCard
    var onSave: (QuickReferenceCard) -> Void
    var onDelete: () -> Void

    init(
        card: QuickReferenceCard,
        onSave: @escaping (QuickReferenceCard) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.card = card
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: card.title)
        _content = State(initialValue: card.content)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BluePDTheme.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.caption)
                                .foregroundColor(BluePDTheme.secondaryText)

                            TextField("Card title", text: $title)
                                .foregroundColor(BluePDTheme.primaryText)
                                .padding()
                                .background(BluePDTheme.cardFill)
                                .cornerRadius(14)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.caption)
                                .foregroundColor(BluePDTheme.secondaryText)

                            TextEditor(text: $content)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(BluePDTheme.primaryText)
                                .frame(minHeight: 280)
                                .padding(10)
                                .background(BluePDTheme.cardFill)
                                .cornerRadius(14)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Created")
                                .font(.caption)
                                .foregroundColor(BluePDTheme.secondaryText)

                            Text(card.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(BluePDTheme.secondaryText)
                        }

                        Button {
                            shareCard()
                        } label: {
                            Label("Share / Export", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BluePDSecondaryButtonStyle())
                        .padding(.top, 8)

                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Text("Delete Card")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BluePDDestructiveButtonStyle())
                    }
                    .padding()
                }
            }
            .navigationTitle("Quick Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BluePDTheme.primaryText)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let updatedCard = QuickReferenceCard(
                            id: card.id,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                            createdAt: card.createdAt
                        )
                        onSave(updatedCard)
                        dismiss()
                    }
                    .foregroundColor(BluePDTheme.primaryText)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(item: $shareFile) { file in
                ShareSheet(items: [file.url])
            }
        }
    }

    private func shareCard() {
        guard let data = PDFReportBuilder.makeTextReportPDF(title: title, body: content) ,
              let url = PDFReportBuilder.writeTemporaryPDF(data: data, suggestedName: title) else {
            return
        }
        shareFile = ShareableFile(url: url)
    }
}

#Preview {
    QuickCardsView()
        .environmentObject(StoreManager())
        .environmentObject(CloudSyncManager())
}
