import Foundation
import SwiftUI
import Services
import AnytypeCore

struct DiscussionVideoBlockView: View {

    private enum Constants {
        static let maxHeight: CGFloat = 600
        static let cornerRadius: CGFloat = 8
        static let thumbnailSize: CGFloat = 400
    }

    let details: MessageAttachmentDetails

    @StateObject private var model = DiscussionVideoThumbnailModel()

    var body: some View {
        ZStack {
            if let image = model.image {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: Constants.maxHeight)
                    MessageMediaUploadingStatus(
                        syncStatus: details.syncStatus,
                        syncError: details.syncError
                    ) {
                        MessageLoadingStateContainer {
                            Image(asset: .Controls.play)
                                .foregroundStyle(Color.white)
                        }
                        .background(.black.opacity(0.5))
                    }
                }
            } else if model.hasError {
                MessageAttachmentErrorIndicator()
                    .frame(height: 200)
            } else {
                MessageAttachmentLoadingIndicator()
                    .frame(height: 200)
            }
        }
        .clipShape(.rect(cornerRadius: Constants.cornerRadius))
        .task {
            guard let url = ContentUrlBuilder.fileUrl(fileId: details.id) else { return }
            let size = CGSize(width: Constants.thumbnailSize, height: Constants.thumbnailSize)
            await model.updatePreview(for: url, size: size)
        }
    }
}

@MainActor
private final class DiscussionVideoThumbnailModel: ObservableObject {

    @Injected(\.videoPreviewStorage)
    private var videoPreviewStorage: any VideoPreviewStorageProtocol

    @Published var image: UIImage?
    @Published var hasError: Bool = false

    func updatePreview(for url: URL, size: CGSize) async {
        do {
            image = try await videoPreviewStorage.preview(url: url, size: size)
        } catch {
            hasError = true
        }
    }
}
