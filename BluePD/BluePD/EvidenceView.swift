import SwiftUI
import PhotosUI

struct EvidenceView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var evidenceItems: [EvidenceRecord] = []
    @State private var evidenceNotes: String = ""
    @State private var caseReference: String = ""

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard
                evidenceSummaryCard
                uploadCard
                galleryCard
                notesCard
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 28)
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
        .navigationTitle("Evidence")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSavedEvidence()
        }
        .onChange(of: selectedItems) { newItems in
            loadSelectedImages(from: newItems)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue.opacity(0.16))
                        .frame(width: 58, height: 58)

                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Evidence Manager")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Store and review case-related images.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer()
            }

            Text("Use this section to attach scene photos, evidence images, and supporting visuals for later review.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
    }

    private var evidenceSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("Evidence Overview")
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(.blue)
            }

            HStack(spacing: 12) {
                summaryTile(
                    title: "\(evidenceItems.count)",
                    subtitle: "Photos Added",
                    systemImage: "photo.on.rectangle.angled"
                )

                summaryTile(
                    title: caseReference.isEmpty ? "Not Set" : caseReference,
                    subtitle: "Case Ref",
                    systemImage: "doc.text.fill"
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var uploadCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("Add Evidence")
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "plus.viewfinder")
                    .foregroundColor(.blue)
            }

            VStack(spacing: 14) {
                StyledEvidenceTextField(
                    title: "Case Reference",
                    text: $caseReference,
                    systemImage: "number.square.fill"
                )

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 20,
                    matching: .images
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 34))
                            .foregroundColor(.blue)

                        Text("Select Evidence Photos")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Tap to add images from the photo library.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.68))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [8, 6]))
                            .foregroundColor(Color.white.opacity(0.18))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var galleryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text("Evidence Gallery")
                        .font(.headline)
                        .foregroundColor(.white)
                } icon: {
                    Image(systemName: "photo.stack.fill")
                        .foregroundColor(.blue)
                }

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
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("Evidence Notes")
                    .font(.headline)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.blue)
            }

            TextEditor(text: $evidenceNotes)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .frame(minHeight: 140)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )

            Text("Add scene details, collection notes, item descriptions, or chain-of-custody reminders.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.68))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 34))
                .foregroundColor(.blue)

            Text("No Evidence Added")
                .font(.headline)
                .foregroundColor(.white)

            Text("Selected photos will appear here for quick review.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.68))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func summaryTile(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 42, height: 42)

                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .font(.headline)
            }

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.68))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func evidenceImageCard(item: EvidenceRecord, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                if let image = item.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.5))
                        )
                }

                HStack {
                    Text("Photo \(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(10)
                .background(Color.white.opacity(0.05))
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )

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
}

struct EvidenceRecord: Codable, Identifiable {
    let id: UUID
    let filename: String

    var uiImage: UIImage? {
        EvidenceStorage.loadImage(named: filename)
    }
}

enum EvidenceStorage {
    private static let manifestFilename = "evidence_manifest.json"

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
}

struct StyledEvidenceTextField: View {
    let title: String
    @Binding var text: String
    let systemImage: String

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
                .autocorrectionDisabled()
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

#Preview {
    NavigationStack {
        EvidenceView()
    }
}
