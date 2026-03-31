import SwiftUI
import PhotosUI
import UIKit

struct EvidenceView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var evidenceItems: [StoredEvidenceItem] = []
    @State private var statusMessage = ""

    private let storage = EvidenceStorageManager()

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 0,
                    matching: .images
                ) {
                    Label("Add Evidence Photos", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.green)
                        .multilineTextAlignment(.center)
                }

                if evidenceItems.isEmpty {
                    emptyStateCard
                } else {
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(evidenceItems) { item in
                            EvidencePhotoCard(
                                item: item,
                                onDelete: {
                                    deleteEvidence(item)
                                }
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Evidence")
        .onAppear {
            loadEvidence()
        }
        .task(id: selectedItems) {
            guard !selectedItems.isEmpty else { return }
            await importSelectedPhotos()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Local Evidence Storage", systemImage: "externaldrive.fill")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Photos added here are stored locally on this device and will remain available after the app is closed.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Saved photos: \(evidenceItems.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private var emptyStateCard: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .frame(height: 260)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 42))

                    Text("No evidence photos saved")
                        .font(.headline)

                    Text("Select one or more photos to store them locally in the app.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
    }

    private func importSelectedPhotos() async {
        statusMessage = ""

        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                do {
                    try storage.saveImageData(data)
                } catch {
                    statusMessage = "Could not save one or more photos."
                }
            }
        }

        selectedItems = []
        loadEvidence()

        if statusMessage.isEmpty {
            statusMessage = "Evidence photos saved locally."
        }
    }

    private func loadEvidence() {
        evidenceItems = storage.loadEvidenceItems()
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func deleteEvidence(_ item: StoredEvidenceItem) {
        do {
            try storage.deleteItem(item)
            evidenceItems.removeAll { $0.id == item.id }
            statusMessage = "Evidence photo deleted."
        } catch {
            statusMessage = "Could not delete evidence photo."
        }
    }
}

struct StoredEvidenceItem: Identifiable, Codable, Equatable {
    let id: UUID
    let fileName: String
    let createdAt: Date
}

private struct EvidencePhotoCard: View {
    let item: StoredEvidenceItem
    let onDelete: () -> Void

    @State private var image: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(.thinMaterial)
                            .overlay {
                                ProgressView()
                            }
                    }
                }
                .frame(height: 180)
                .clipped()

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.caption.bold())
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(8)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.fileName)
                    .font(.caption)
                    .lineLimit(1)

                Text(formattedDate(item.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task {
            image = EvidenceStorageManager().loadUIImage(for: item)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct EvidenceStorageManager {
    private let folderName = "SavedEvidence"
    private let metadataFileName = "evidence_metadata.json"

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var evidenceFolderURL: URL {
        documentsURL.appendingPathComponent(folderName, isDirectory: true)
    }

    private var metadataURL: URL {
        evidenceFolderURL.appendingPathComponent(metadataFileName)
    }

    init() {
        createFolderIfNeeded()
    }

    func saveImageData(_ data: Data) throws {
        createFolderIfNeeded()

        let id = UUID()
        let fileName = "\(id.uuidString).jpg"
        let fileURL = evidenceFolderURL.appendingPathComponent(fileName)

        if let image = UIImage(data: data),
           let jpegData = image.jpegData(compressionQuality: 0.9) {
            try jpegData.write(to: fileURL, options: .atomic)
        } else {
            try data.write(to: fileURL, options: .atomic)
        }

        var items = loadEvidenceItems()
        let newItem = StoredEvidenceItem(
            id: id,
            fileName: fileName,
            createdAt: Date()
        )
        items.append(newItem)
        try saveMetadata(items)
    }

    func loadEvidenceItems() -> [StoredEvidenceItem] {
        createFolderIfNeeded()

        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: metadataURL)
            return try JSONDecoder().decode([StoredEvidenceItem].self, from: data)
        } catch {
            return []
        }
    }

    func loadUIImage(for item: StoredEvidenceItem) -> UIImage? {
        let fileURL = evidenceFolderURL.appendingPathComponent(item.fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    func deleteItem(_ item: StoredEvidenceItem) throws {
        let fileURL = evidenceFolderURL.appendingPathComponent(item.fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        var items = loadEvidenceItems()
        items.removeAll { $0.id == item.id }
        try saveMetadata(items)
    }

    private func saveMetadata(_ items: [StoredEvidenceItem]) throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: metadataURL, options: .atomic)
    }

    private func createFolderIfNeeded() {
        if !FileManager.default.fileExists(atPath: evidenceFolderURL.path) {
            try? FileManager.default.createDirectory(
                at: evidenceFolderURL,
                withIntermediateDirectories: true
            )
        }
    }
}
