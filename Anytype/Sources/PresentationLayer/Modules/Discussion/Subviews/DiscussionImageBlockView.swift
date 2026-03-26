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

    private var imageHeight: CGFloat? {
        guard let w = details.widthInPixels, let h = details.heightInPixels, w > 0 else { return nil }
        return nil // calculated per available width in body
    }

    var body: some View {
        GeometryReader { geometry in
            let size = imageSize(availableWidth: geometry.size.width)
            CachedAsyncImage(
                url: ImageMetadata(id: details.id, side: .original).contentUrl
            ) { content in
                switch content {
                case .empty:
                    MessageAttachmentLoadingIndicator()
                        .frame(width: size.width, height: size.height)
                case .success(let image):
                    ZStack {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipped()
                        MessageMediaUploadingStatus(syncStatus: details.syncStatus, syncError: details.syncError)
                    }
                    .clipShape(.rect(cornerRadius: Constants.cornerRadius))
                case .failure:
                    MessageAttachmentErrorIndicator()
                        .frame(width: size.width, height: size.height)
                @unknown default:
                    MessageAttachmentLoadingIndicator()
                        .frame(width: size.width, height: size.height)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: fixedHeight)
    }

    private var fixedHeight: CGFloat {
        // Screen width as approximation — GeometryReader will refine
        let screenWidth = UIScreen.main.bounds.width - 32
        return imageSize(availableWidth: screenWidth).height
    }

    private func imageSize(availableWidth: CGFloat) -> CGSize {
        guard let w = details.widthInPixels, let h = details.heightInPixels, w > 0, h > 0 else {
            return CGSize(width: availableWidth, height: Constants.placeholderHeight)
        }

        let aspectRatio = CGFloat(w) / CGFloat(h)
        let fittedHeight = availableWidth / aspectRatio
        let clampedHeight = min(fittedHeight, Constants.maxHeight)
        let finalWidth = clampedHeight < fittedHeight ? clampedHeight * aspectRatio : availableWidth

        return CGSize(width: finalWidth, height: clampedHeight)
    }
}
