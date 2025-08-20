import Foundation
import UIKit

struct MessageBigBookmarkLayout: Equatable {
    let size: CGSize
    let imageFrame: CGRect?
    let hostFrame: CGRect?
    let titleFrame: CGRect?
    let descriptionFrame: CGRect?
}

struct MessageBigBookmarkCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageBigBookmarkViewData) -> MessageBigBookmarkLayout {
        
        let textInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        let spacingBetweenText: CGFloat = 2
        
        let imageSize = data.pictureId.isNotEmpty
            ? CGSize(width: targetSize.width, height: targetSize.width * 0.5)
            : nil
        
        let textWidth = targetSize.width - textInsets.left - textInsets.right
        
        let hostSize = data.host.string.isNotEmpty
            ? data.host.sizeForLabel(width: textWidth, maxLines: data.hostLineLimit)
            : nil
        
        let titleSize = data.title.string.isNotEmpty
            ? data.title.sizeForLabel(width: textWidth, maxLines: data.titleLineLimit)
            : nil
        
        let descriptionSize = data.description.string.isNotEmpty
            ? data.description.sizeForLabel(width: textWidth, maxLines: data.descriptionLineLimit)
            : nil
        
        
        var imageFrame: CGRect?
        var hostFrame: CGRect?
        var titleFrame: CGRect?
        var descriptionFrame: CGRect?
        
        var nextItemMaxY: CGFloat = 0
        
        if let imageSize {
            imageFrame = CGRect(origin: .zero, size: imageSize)
            nextItemMaxY += (imageSize.height + textInsets.top)
        } else {
            nextItemMaxY += textInsets.top
        }
        
        if let hostSize {
            hostFrame = CGRect(origin: CGPoint(x: textInsets.left, y: nextItemMaxY), size: hostSize)
            nextItemMaxY += (hostSize.height + spacingBetweenText)
        }
        
        if let titleSize {
            titleFrame = CGRect(origin: CGPoint(x: textInsets.left, y: nextItemMaxY), size: titleSize)
            nextItemMaxY += (titleSize.height + spacingBetweenText)
        }
        
        if let descriptionSize {
            descriptionFrame = CGRect(origin: CGPoint(x: textInsets.left, y: nextItemMaxY), size: descriptionSize)
        }
        
        let height = max(imageFrame?.maxY ?? 0, hostFrame?.maxY ?? 0, titleFrame?.maxY ?? 0, descriptionFrame?.maxY ?? 0) + textInsets.bottom
        
        let size = CGSize(width: targetSize.width, height: height)
        
        return MessageBigBookmarkLayout(
            size: size,
            imageFrame: imageFrame,
            hostFrame: hostFrame,
            titleFrame: titleFrame,
            descriptionFrame: descriptionFrame
        )
    }
}
