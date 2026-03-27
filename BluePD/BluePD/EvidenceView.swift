import SwiftUI
import PhotosUI
import UIKit

struct EvidenceView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .frame(height: 240)
                        .overlay {
                            VStack(spacing: 10) {
                                Image(systemName: "photo")
                                    .font(.system(size: 42))
                                Text("No evidence photo selected")
                                    .foregroundStyle(.secondary)
                            }
                        }
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Select Evidence Photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)

                Text("This demo build stores only the currently selected image in memory. Add secure local storage or cloud sync in a later version.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Evidence")
        .task(id: selectedItem) {
            guard let selectedItem else { return }
            selectedImageData = try? await selectedItem.loadTransferable(type: Data.self)
        }
    }
}
