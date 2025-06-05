import SwiftUI
import CachedAsyncImage

struct MessageImageView: View {
    
    let imageId: String
    
    init(imageId: String) {
        self.imageId = imageId
    }
    
    var body: some View {
        GeometryReader { reader in
            CachedAsyncImage(
                url: ImageMetadata(id: imageId, side: .width(min(reader.size.width, reader.size.height))).contentUrl
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
