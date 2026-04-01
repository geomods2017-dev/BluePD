import SwiftUI
import PhotosUI

struct EvidenceView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var evidenceItems: [EvidenceRecord] = []
    @State private var evidenceNotes: String = ""
    @State private var caseReference: String = ""

    @FocusState private var isNotesFocused: Bool
    @FocusState private var isCaseReferenceFocused: Bool

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                topHeader
                overviewSection
                addEvidenceSection
                gallerySection
                notesSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 28)
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
            loadSelectedImages(from: newItems)
        }
        .onChange(of: caseReference) { _ in
            saveMetadata()
        }
        .onChange(of: evidenceNotes) { _ in
            saveMetadata()
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

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.blue.opacity(0.14))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Evidence Manager")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Store and review case-related images")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.68))
                }

                Spacer()
            }

            Text(headerSubtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.82))
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Overview")

            HStack(spacing: 12) {
                compactSummaryCard(
                    title: "\(evidenceItems.count)",
                    subtitle: "Photos",
                    systemImage: "photo.on.rectangle.angled"
                )

                compactSummaryCard(
                    title: caseReference.trimmedOrFallback("Not Set"),
                    subtitle: "Case Ref",
                    systemImage: "doc.text.fill"
                )
            }
        }
    }

    private var addEvidenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Add Evidence")

            VStack(spacing: 12) {
                StyledEvidenceTextField(
                    title: "Case Reference",
                    text: $caseReference,
                    systemImage: "number.square.fill",
                    isFocused: $isCaseReferenceFocused
                )

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 20,
                    matching: .images
                ) {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.blue)

                        Text("Select Evidence Photos")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Add photos from the library")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.62))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.045))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 1.1, dash: [7, 5]))
                            .foregroundColor(Color.white.opacity(0.16))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Gallery")

                Spacer()

                if !evidenceItems.isEmpty {
                    Button("Clear All") {
                        clearAllEvidence()
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }

            if evidenceItems.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(Array(evidenceItems.enumerated()), id: \.element.id) { index, item in
                        evidenceImageCard(item: item, index: index)
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Evidence Notes")

            ZStack(alignment: .topLeading) {
                if evidenceNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Add scene details, collection notes, item descriptions, or chain-of-custody reminders.")
                        .foregroundColor(.white.opacity(0.28))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                }

                TextEditor(text: $evidenceNotes)
                    .focused($isNotesFocused)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .frame(minHeight: 150)
                    .padding(10)
                    .background(Color.clear)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.045))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }

    private var headerSubtitle: String {
        let reference = caseReference.trimmingCharacters(in: .whitespacesAndNewlines)
        return reference.isEmpty ? "Attach and review evidence images in one place" : "Current case reference: \(reference)"
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
    }

    private func compactSummaryCard(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.blue.opacity(0.10))
                )

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.60))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 30))
                .foregroundColor(.blue)

            Text("No Evidence Added")
                .font(.headline)
                .foregroundColor(.white)

            Text("Selected photos will appear here for quick review.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.62))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(innerCardBackground)
        .overlay(innerCardBorder)
    }

    private func evidenceImageCard(item: EvidenceRecord, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                if let image = item.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 142)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 142)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.45))
                        )
                }

                HStack {
                    Text("Photo \(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background(Color.white.opacity(0.04))
            }
            .background(innerCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(innerCardBorder)

            Button {
                removeImage(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            .padding(8)
        }
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

    private func dismissKeyboard() {
        isNotesFocused = false
        isCaseReferenceFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func loadSelectedImages(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let savedFilename = EvidenceStorage.saveImage(image) {
                    let newRecord = EvidenceRecord(id: UUID(), filename: savedFilename)
                    evidenceItems.append(newRecord)
                }
            }

            EvidenceStorage.saveManifest(evidenceItems)
            selectedItems.removeAll()
        }
    }

    private func removeImage(at index: Int) {
        guard evidenceItems.indices.contains(index) else { return }

        let item = evidenceItems[index]
        EvidenceStorage.deleteImage(named: item.filename)
        evidenceItems.remove(at: index)
        EvidenceStorage.saveManifest(evidenceItems)
    }

    private func clearAllEvidence() {
        for item in evidenceItems {
            EvidenceStorage.deleteImage(named: item.filename)
        }

        evidenceItems.removeAll()
        selectedItems.removeAll()
        EvidenceStorage.saveManifest(evidenceItems)
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
                .focused(isFocused)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
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
