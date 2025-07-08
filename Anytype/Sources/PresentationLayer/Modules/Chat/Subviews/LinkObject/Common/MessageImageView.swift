import SwiftUI
import Services

struct MessageImageView: View {
    
    let imageId: String
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    
    var body: some View {
        GeometryReader { reader in
            ToggleCachedAsyncImage(
                url: ImageMetadata(id: imageId, side: .width(min(reader.size.width, reader.size.height))).contentUrl,
                urlCache: .anytypeImages
            ) { content in
                switch content {
                case .empty:
                    MessageAttachmentLoadingIndicator()
                case .success(let image):
                    ZStack {
                        image.resizable().scaledToFill()
                            .frame(width: reader.size.width, height: reader.size.height, alignment: .center)
                            .clipped()
                        MessageUploadingStatus(syncStatus: syncStatus, syncError: syncError)
                    }
                case .failure:
                    MessageAttachmentErrorIndicator()
                @unknown default:
                    MessageAttachmentLoadingIndicator()
                }
            }
        }
    }
}

extension MessageImageView {
    init(details: MessageAttachmentDetails) {
        self.init(imageId: details.id, syncStatus: details.syncStatus, syncError: details.syncError)
    }
}
