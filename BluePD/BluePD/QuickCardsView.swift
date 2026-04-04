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

    @State private var cards: [QuickReferenceCard] = []
    @State private var searchText = ""
    @State private var selectedCard: QuickReferenceCard?
    @State private var showCreateCard = false
    @State private var showUpgradeAlert = false
    @State private var isPurchasingPro = false
    @State private var statusMessage = ""

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
                backgroundGradient
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
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                loadCards()
            }
            .sheet(isPresented: $showCreateCard) {
                CreateQuickCardView { newCard in
                    cards.insert(newCard, at: 0)
                    QuickCardStorage.save(cards)
                    statusMessage = "Quick card saved."
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
            HStack(spacing: 12) {
                Image(systemName: "rectangle.stack.text.card.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.blue.opacity(0.14))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Reference Cards")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Create personalized quick-access field notes")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.68))
                }

                Spacer()
            }

            Text("Store your own reminders, statutes, notes, procedures, or checklists for fast access.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.82))
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
        .padding(.horizontal, 16)
    }

    private var storageBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: storeManager.isPro ? "checkmark.seal.fill" : "rectangle.stack.fill")
                    .foregroundColor(storeManager.isPro ? .green : .blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(storeManager.isPro ? "BluePD Pro Active" : "Free Quick Cards")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(storeManager.isPro ? "Unlimited custom cards available" : "\(cards.count)/\(freeCardLimit) cards used")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer()
            }

            if hasReachedFreeCardLimit {
                Text("Free card limit reached. Upgrade to BluePD Pro for unlimited custom cards.")
                    .font(.caption)
                    .foregroundColor(.orange.opacity(0.95))
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.72))
            }
        }
        .padding(14)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
        .padding(.horizontal, 16)
    }

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.55))

            TextField("Search quick cards", text: $searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
        }
        .padding(14)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
        .padding(.horizontal, 16)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "rectangle.stack.text.card")
                .font(.system(size: 42))
                .foregroundColor(.blue)

            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No Quick Cards Yet" : "No Matching Cards")
                .font(.headline)
                .foregroundColor(.white)

            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                 ? "Create a custom quick card to store notes, procedures, or reminders."
                 : "Try a different search term.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.62))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Button {
                createCardTapped()
            } label: {
                Text("Create Quick Card")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }

    private func quickCardRow(_ card: QuickReferenceCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(card.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.45))
            }

            Text(card.content)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Text(card.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(14)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.055))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.white.opacity(0.06), lineWidth: 1)
    }

    private var innerCardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.white.opacity(0.045))
    }

    private var innerCardBorder: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
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
    }

    private func deleteCard(_ card: QuickReferenceCard) {
        cards.removeAll { $0.id == card.id }
        QuickCardStorage.save(cards)
        statusMessage = "Quick card deleted."
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
}

struct CreateQuickCardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""

    var onSave: (QuickReferenceCard) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
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

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.65))

                        TextField("Enter card title", text: $title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.65))

                        TextEditor(text: $content)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.white)
                            .frame(minHeight: 220)
                            .padding(10)
                            .background(Color.white.opacity(0.05))
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
                    .foregroundColor(.white)
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
                    .foregroundColor(.white)
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

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.65))

                            TextField("Card title", text: $title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(14)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.65))

                            TextEditor(text: $content)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.white)
                                .frame(minHeight: 280)
                                .padding(10)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(14)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Created")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.65))

                            Text(card.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.72))
                        }

                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Text("Delete Card")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.top, 8)
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
                    .foregroundColor(.white)
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
                    .foregroundColor(.white)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuickCardsView()
            .environmentObject(StoreManager())
    }
}
