import Foundation
import SwiftUI
import Services

struct DiscussionImageBlockView: View {

    private enum Constants {
        static let maxHeight: CGFloat = 600
        static let cornerRadius: CGFloat = 8
        static let placeholderHeight: CGFloat = 200
    }

    let details: MessageAttachmentDetails

    private var aspectRatio: CGFloat? {
        guard let w = details.widthInPixels, let h = details.heightInPixels, w > 0, h > 0 else { return nil }
        return CGFloat(w) / CGFloat(h)
    }

    var body: some View {
        CachedAsyncImage(
            url: ImageMetadata(id: details.id, side: .original).contentUrl
        ) { content in
            switch content {
            case .empty:
                MessageAttachmentLoadingIndicator()
            case .success(let image):
                ZStack {
                    image
                        .resizable()
                        .scaledToFill()
                    MessageMediaUploadingStatus(syncStatus: details.syncStatus, syncError: details.syncError)
                }
                .clipShape(.rect(cornerRadius: Constants.cornerRadius))
            case .failure:
                MessageAttachmentErrorIndicator()
            @unknown default:
                MessageAttachmentLoadingIndicator()
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .frame(maxHeight: Constants.maxHeight)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
