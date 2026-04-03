import SwiftUI
import Services

struct MessageImageView: View {
    
    let imageId: String
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    let sizeInBytes: Int?
    let uploadTimeMs: Int?

    var body: some View {
        GeometryReader { reader in
            CachedAsyncImage(url: ImageMetadata(id: imageId, side: .width(min(reader.size.width, reader.size.height))).contentUrl) { content in
                switch content {
                case .empty:
                    MessageAttachmentLoadingIndicator()
                case .success(let image):
                    ZStack {
                        image.resizable().scaledToFill()
                            .frame(width: reader.size.width, height: reader.size.height, alignment: .center)
                            .clipped()
                        MessageMediaUploadingStatus(syncStatus: syncStatus, syncError: syncError)
                    }
                case .failure:
                    MessageAttachmentErrorIndicator()
                @unknown default:
                    MessageAttachmentLoadingIndicator()
                }
            } loadTimeTracker: { time, success in
                var totalTime: Int? = nil
                if let uploadTimeMs {
                    totalTime = uploadTimeMs + time
                }
                AnytypeAnalytics.instance().logScreenChatImage(
                    time: time,
                    status: success ? .success : .failure,
                    size: sizeInBytes,
                    uploadTime: uploadTimeMs,
                    totalTime: totalTime
                )
            }
        }
    }
}

extension MessageImageView {
    init(details: MessageAttachmentDetails) {
        self.init(
            imageId: details.id,
            syncStatus: details.syncStatus,
            syncError: details.syncError,
            sizeInBytes: details.sizeInBytes,
            uploadTimeMs: details.uploadTimeMs
        )
    }
}
