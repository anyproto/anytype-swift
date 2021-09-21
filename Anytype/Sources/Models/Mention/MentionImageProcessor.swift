import Kingfisher
import CoreGraphics

struct MentionImageProcessor: ImageProcessor {
    let identifier: String
    let rightPadding: CGFloat
    
    init(rightPadding: CGFloat) {
        self.rightPadding = rightPadding
        self.identifier = "com.anytype.MentionImageProcessor.\(rightPadding)"
    }
    
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            let imageWithPaddingSize = image.size + CGSize(width: rightPadding, height: 0)
            return image.imageDrawn(on: imageWithPaddingSize, offset: .zero)
        case .data: return (DefaultImageProcessor.default |> self).process(item: item, options: options)
        }
    }
}
