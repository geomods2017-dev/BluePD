import SwiftUI
import PhotosUI

struct EvidenceView: View {
    @EnvironmentObject var storeManager: StoreManager

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var evidenceItems: [EvidenceRecord] = []
    @State private var evidenceNotes: String = ""
    @State private var caseReference: String = ""

    @State private var showUpgradeAlert = false
    @State private var isPurchasingPro = false
    @State private var evidenceStatusMessage = ""

    @FocusState private var isNotesFocused: Bool
    @FocusState private var isCaseReferenceFocused: Bool

    private let freeEvidenceLimit = 10

    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var hasReachedFreeEvidenceLimit: Bool {
        !storeManager.isPro && evidenceItems.count >= freeEvidenceLimit
    }

    private var remainingFreeSlots: Int {
        max(0, freeEvidenceLimit - evidenceItems.count)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                topHeader
                storageStatusSection
                overviewSection
                addEvidenceSection
                gallerySection
                notesSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Evidence")
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
        .onAppear {
            loadSavedEvidence()
            loadSavedMetadata()
        }
        .onChange(of: selectedItems) { newItems in
            handleSelectedItems(newItems)
        }
        .onChange(of: caseReference) { _ in
            saveMetadata()
        }
        .onChange(of: evidenceNotes) { _ in
            saveMetadata()
        }
        .alert("Upgrade to BluePD Pro", isPresented: $showUpgradeAlert) {
            Button(isPurchasingPro ? "Purchasing..." : "Upgrade") {
                purchasePro()
            }
            .disabled(isPurchasingPro)

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Free users can store up to \(freeEvidenceLimit) evidence items. Upgrade to BluePD Pro for unlimited evidence storage.")
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 2/255, green: 7/255, blue: 18/255),
                Color(red: 7/255, green: 17/255, blue: 31/255),
                Color(red: 10/255, green: 24/255, blue: 44/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                iconContainer(systemImage: "camera.viewfinder", size: 56, iconSize: 22)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Evidence Manager")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(EvidencePalette.primaryText)

                    Text("Store and review case-related images")
                        .font(.subheadline)
                        .foregroundStyle(EvidencePalette.secondaryText)
                }

                Spacer()
            }

            Text(headerSubtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(EvidencePalette.primaryText.opacity(0.92))
        }
        .padding(20)
        .bluePDCard(cornerRadius: 24)
    }

    private var storageStatusSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill((storeManager.isPro ? Color.green : Color.blue).opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke((storeManager.isPro ? Color.green : Color.blue).opacity(0.25), lineWidth: 1)
                        )

                    Image(systemName: storeManager.isPro ? "checkmark.seal.fill" : "externaldrive.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(storeManager.isPro ? Color.green : EvidencePalette.accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(storeManager.isPro ? "BluePD Pro Active" : "Free Evidence Storage")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(EvidencePalette.primaryText)

                    Text(storeManager.isPro
                         ? "Unlimited evidence storage available"
                         : "\(evidenceItems.count)/\(freeEvidenceLimit) evidence items used")
                        .font(.subheadline)
                        .foregroundStyle(EvidencePalette.secondaryText)
                }

                Spacer()
            }

            if hasReachedFreeEvidenceLimit {
                Text("Free evidence limit reached. Upgrade to BluePD Pro for unlimited evidence storage.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.orange.opacity(0.95))
            }

            if !evidenceStatusMessage.isEmpty {
                Text(evidenceStatusMessage)
                    .font(.caption)
                    .foregroundStyle(EvidencePalette.secondaryText)
            }
        }
        .padding(18)
        .bluePDCard(cornerRadius: 24)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Overview")

            HStack(spacing: 14) {
                compactSummaryCard(
                    title: "\(evidenceItems.count)",
                    subtitle: "Photos",
                    systemImage: "photo.on.rectangle.angled"
                )

                compactSummaryCard(
                    title: caseReference.trimmedOrFallback("No Case Ref"),
                    subtitle: "Case Reference",
                    systemImage: "doc.text.fill"
                )
            }
        }
    }

    private var addEvidenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Add Evidence")

            VStack(spacing: 14) {
                StyledEvidenceTextField(
                    title: "Case Reference",
                    text: $caseReference,
                    systemImage: "number.square.fill",
                    isFocused: $isCaseReferenceFocused
                )

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: storeManager.isPro ? 20 : max(remainingFreeSlots, 1),
                    matching: .images
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: hasReachedFreeEvidenceLimit ? "lock.fill" : "photo.badge.plus")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(hasReachedFreeEvidenceLimit ? Color.orange : EvidencePalette.accent)

                        Text(hasReachedFreeEvidenceLimit ? "Free Limit Reached" : "Select Evidence Photos")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(EvidencePalette.primaryText)

                        Text(
                            hasReachedFreeEvidenceLimit
                            ? "Upgrade to BluePD Pro to add more evidence."
                            : "Add photos from the library."
                        )
                        .font(.subheadline)
                        .foregroundStyle(EvidencePalette.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.045))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 1.1, dash: [7, 5]))
                            .foregroundStyle(Color.white.opacity(0.16))
                    )
                }
                .buttonStyle(.plain)
                .disabled(hasReachedFreeEvidenceLimit)
            }
        }
    }

    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                sectionHeader("Gallery")

                Spacer()

                if !evidenceItems.isEmpty {
                    Button("Clear All") {
                        clearAllEvidence()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.red.opacity(0.95))
                }
            }

            if evidenceItems.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: gridColumns, spacing: 14) {
                    ForEach(Array(evidenceItems.enumerated()), id: \.element.id) { index, item in
                        evidenceImageCard(item: item, index: index)
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Evidence Notes")

            ZStack(alignment: .topLeading) {
                if evidenceNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Add scene details, collection notes, item descriptions, or chain-of-custody reminders.")
                        .foregroundStyle(EvidencePalette.placeholderText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                }

                TextEditor(text: $evidenceNotes)
                    .focused($isNotesFocused)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(EvidencePalette.primaryText)
                    .frame(minHeight: 160)
                    .padding(12)
                    .background(Color.clear)
            }
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.050),
                                Color.white.opacity(0.028)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.065), lineWidth: 1)
            )
        }
    }

    private var headerSubtitle: String {
        let reference = caseReference.trimmingCharacters(in: .whitespacesAndNewlines)
        return reference.isEmpty
            ? "Attach and review evidence images in one place"
            : "Current case reference: \(reference)"
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(EvidencePalette.accent)
                .frame(width: 5, height: 24)

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(EvidencePalette.primaryText)

            Spacer()
        }
        .padding(.horizontal, 2)
    }

    private func compactSummaryCard(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            iconContainer(systemImage: systemImage, size: 44, iconSize: 17)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(EvidencePalette.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.80)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(EvidencePalette.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .bluePDInnerCard(cornerRadius: 22)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 34))
                .foregroundStyle(EvidencePalette.accent)

            Text("No Evidence Added")
                .font(.title3.weight(.semibold))
                .foregroundStyle(EvidencePalette.primaryText)

            Text("Photos you attach to this case will appear here for review.")
                .font(.subheadline)
                .foregroundStyle(EvidencePalette.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .bluePDInnerCard(cornerRadius: 22)
    }

    private func evidenceImageCard(item: EvidenceRecord, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                if let image = item.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 148)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 148)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(EvidencePalette.secondaryText)
                        )
                }

                HStack {
                    Text("Photo \(index + 1)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(EvidencePalette.primaryText)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.04))
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.050),
                                Color.white.opacity(0.028)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.065), lineWidth: 1)
            )

            Button {
                removeImage(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .background(Color.black.opacity(0.40))
                    .clipShape(Circle())
            }
            .padding(10)
        }
    }

    private func iconContainer(systemImage: String, size: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.blue.opacity(0.22), lineWidth: 1)
                )

            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(EvidencePalette.accent)
        }
        .frame(width: size, height: size)
    }

    private func dismissKeyboard() {
        isNotesFocused = false
        isCaseReferenceFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func handleSelectedItems(_ items: [PhotosPickerItem]) {
        evidenceStatusMessage = ""

        guard !items.isEmpty else { return }

        if hasReachedFreeEvidenceLimit {
            selectedItems.removeAll()
            showUpgradeAlert = true
            return
        }

        let allowableItems: [PhotosPickerItem]
        if storeManager.isPro {
            allowableItems = items
        } else {
            allowableItems = Array(items.prefix(remainingFreeSlots))
            if items.count > allowableItems.count {
                evidenceStatusMessage = "Free plan allows \(remainingFreeSlots) more evidence item\(remainingFreeSlots == 1 ? "" : "s")."
            }
        }

        loadSelectedImages(from: allowableItems)
    }

    private func loadSelectedImages(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if !storeManager.isPro && evidenceItems.count >= freeEvidenceLimit {
                    await MainActor.run {
                        evidenceStatusMessage = "Free evidence limit reached."
                        showUpgradeAlert = true
                    }
                    break
                }

                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let savedFilename = EvidenceStorage.saveImage(image) {
                    let newRecord = EvidenceRecord(id: UUID(), filename: savedFilename)

                    await MainActor.run {
                        evidenceItems.append(newRecord)
                    }
                }
            }

            await MainActor.run {
                EvidenceStorage.saveManifest(evidenceItems)
                selectedItems.removeAll()

                if evidenceStatusMessage.isEmpty {
                    evidenceStatusMessage = "Evidence updated."
                }
            }
        }
    }

    private func removeImage(at index: Int) {
        guard evidenceItems.indices.contains(index) else { return }

        let item = evidenceItems[index]
        EvidenceStorage.deleteImage(named: item.filename)
        evidenceItems.remove(at: index)
        EvidenceStorage.saveManifest(evidenceItems)
        evidenceStatusMessage = "Evidence item removed."
    }

    private func clearAllEvidence() {
        for item in evidenceItems {
            EvidenceStorage.deleteImage(named: item.filename)
        }

        evidenceItems.removeAll()
        selectedItems.removeAll()
        EvidenceStorage.saveManifest(evidenceItems)
        evidenceStatusMessage = "All evidence cleared."
    }

    private func loadSavedEvidence() {
        evidenceItems = EvidenceStorage.loadManifest()
    }

    private func saveMetadata() {
        EvidenceStorage.saveMetadata(
            EvidenceMetadata(
                caseReference: caseReference,
                evidenceNotes: evidenceNotes
            )
        )
    }

    private func loadSavedMetadata() {
        let metadata = EvidenceStorage.loadMetadata()
        caseReference = metadata.caseReference
        evidenceNotes = metadata.evidenceNotes
    }

    private func purchasePro() {
        guard !isPurchasingPro else { return }

        isPurchasingPro = true
        evidenceStatusMessage = "Contacting App Store..."

        Task {
            await storeManager.purchase()

            await MainActor.run {
                isPurchasingPro = false

                if storeManager.isPro {
                    evidenceStatusMessage = "BluePD Pro unlocked. You now have unlimited evidence storage."
                } else {
                    evidenceStatusMessage = "Purchase was not completed."
                }
            }
        }
    }
}

struct EvidenceRecord: Codable, Identifiable {
    let id: UUID
    let filename: String

    var uiImage: UIImage? {
        EvidenceStorage.loadImage(named: filename)
    }
}

struct EvidenceMetadata: Codable {
    let caseReference: String
    let evidenceNotes: String

    init(caseReference: String = "", evidenceNotes: String = "") {
        self.caseReference = caseReference
        self.evidenceNotes = evidenceNotes
    }
}

enum EvidenceStorage {
    private static let manifestFilename = "evidence_manifest.json"
    private static let metadataFilename = "evidence_metadata.json"

    static func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func saveImage(_ image: UIImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = documentsURL().appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        do {
            try data.write(to: url)
            return filename
        } catch {
            return nil
        }
    }

    static func loadImage(named filename: String) -> UIImage? {
        let url = documentsURL().appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func deleteImage(named filename: String) {
        let url = documentsURL().appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    static func saveManifest(_ items: [EvidenceRecord]) {
        let url = documentsURL().appendingPathComponent(manifestFilename)
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: url)
        }
    }

    static func loadManifest() -> [EvidenceRecord] {
        let url = documentsURL().appendingPathComponent(manifestFilename)
        guard let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([EvidenceRecord].self, from: data) else {
            return []
        }
        return items
    }

    static func saveMetadata(_ metadata: EvidenceMetadata) {
        let url = documentsURL().appendingPathComponent(metadataFilename)
        if let data = try? JSONEncoder().encode(metadata) {
            try? data.write(to: url)
        }
    }

    static func loadMetadata() -> EvidenceMetadata {
        let url = documentsURL().appendingPathComponent(metadataFilename)
        guard let data = try? Data(contentsOf: url),
              let metadata = try? JSONDecoder().decode(EvidenceMetadata.self, from: data) else {
            return EvidenceMetadata()
        }
        return metadata
    }
}

struct StyledEvidenceTextField: View {
    let title: String
    @Binding var text: String
    let systemImage: String
    let isFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(EvidencePalette.accent)

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(EvidencePalette.secondaryText)
            }

            TextField(title, text: $text)
                .focused(isFocused)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .foregroundStyle(EvidencePalette.primaryText)
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
    }
}

private enum EvidencePalette {
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.74)
    static let placeholderText = Color.white.opacity(0.34)
    static let accent = Color(red: 0.10, green: 0.56, blue: 1.00)
}

private struct BluePDCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.070),
                                Color.white.opacity(0.032)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
    }
}

private struct BluePDInnerCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.050),
                                Color.white.opacity(0.028)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.065), lineWidth: 1)
            )
    }
}

private extension View {
    func bluePDCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(BluePDCardModifier(cornerRadius: cornerRadius))
    }

    func bluePDInnerCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(BluePDInnerCardModifier(cornerRadius: cornerRadius))
    }
}

private extension String {
    func trimmedOrFallback(_ fallback: String) -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

#Preview {
    NavigationStack {
        EvidenceView()
    }
}
