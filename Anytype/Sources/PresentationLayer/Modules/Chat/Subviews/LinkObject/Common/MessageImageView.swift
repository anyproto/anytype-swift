import SwiftUI
import Services

struct MessageImageView: View {
    
    let details: MessageAttachmentDetails
    
    var body: some View {
        GeometryReader { reader in
            ToggleCachedAsyncImage(
                url: ImageMetadata(id: details.id, side: .width(min(reader.size.width, reader.size.height))).contentUrl,
                urlCache: .anytypeImages
            ) { content in
                switch content {
                case .empty:
                    MessageAttachmentLoadingIndicator()
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    MessageAttachmentErrorIndicator()
                @unknown default:
                    MessageAttachmentLoadingIndicator()
                }
            }
        }
    }
}
