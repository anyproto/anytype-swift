import Foundation
import SwiftUI
import Services

struct DiscussionImageBlockView: View {

    private enum Constants {
        static let maxHeight: CGFloat = 600
        static let cornerRadius: CGFloat = 8
    }

    let details: MessageAttachmentDetails

    var body: some View {
        CachedAsyncImage(
            url: ImageMetadata(id: details.id, side: .original).contentUrl
        ) { content in
            switch content {
            case .empty:
                MessageAttachmentLoadingIndicator()
                    .frame(height: 200)
            case .success(let image):
                ZStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: Constants.maxHeight)
                        .clipShape(.rect(cornerRadius: Constants.cornerRadius))
                    MessageMediaUploadingStatus(syncStatus: details.syncStatus, syncError: details.syncError)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            case .failure:
                MessageAttachmentErrorIndicator()
                    .frame(height: 200)
            @unknown default:
                MessageAttachmentLoadingIndicator()
                    .frame(height: 200)
            }
        }
    }
}
