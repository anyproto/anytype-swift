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
        
        var imageFrame: CGRect?
        var hostFrame: CGRect?
        var titleFrame: CGRect?
        var descriptionFrame: CGRect?
        var size: CGSize?
        
        VStackCalculator(alignment: .left, frameWriter: { size = $0.size }) {
            if data.pictureId.isNotEmpty {
                AnyViewCalculator { targetSize in
                    CGSize(width: targetSize.width, height: targetSize.width * 0.5)
                } frameWriter: {
                    imageFrame = $0
                }
            }
            HStackCauculator {
                VStackCalculator(alignment: .left, spacing: 2) {
                    if data.host.string.isNotEmpty {
                        AnyViewCalculator { targetSize in
                            data.host.sizeForLabel(width: targetSize.width, maxLines: data.hostLineLimit)
                        } frameWriter: {
                            hostFrame = $0
                        }
                    }
                    
                    if data.title.string.isNotEmpty {
                        AnyViewCalculator { targetSize in
                            data.title.sizeForLabel(width: targetSize.width, maxLines: data.titleLineLimit)
                        } frameWriter: {
                            titleFrame = $0
                        }
                    }
                    
                    if data.description.string.isNotEmpty {
                        AnyViewCalculator { targetSize in
                            data.description.sizeForLabel(width: targetSize.width, maxLines: data.descriptionLineLimit)
                        } frameWriter: {
                            descriptionFrame = $0
                        }
                    }
                }
                .padding(horizontal: 12, vertical: 8)
                
                HorizontalSpacerCalculator()
            }
        }
        .calculate(targetSize)
        
//        let spacingBetweenText: CGFloat = 2
//        
//        let imageSize = data.pictureId.isNotEmpty
//            ? CGSize(width: targetSize.width, height: targetSize.width * 0.5)
//            : nil
//        
//        let textWidth = targetSize.width - textInsets.left - textInsets.right
//        
//        let hostSize = data.host.string.isNotEmpty
//            ? data.host.sizeForLabel(width: textWidth, maxLines: data.hostLineLimit)
//            : nil
        
//        let titleSize = data.title.string.isNotEmpty
//            ? data.title.sizeForLabel(width: textWidth, maxLines: data.titleLineLimit)
//            : nil
        
//        let descriptionSize = data.description.string.isNotEmpty
//            ? data.description.sizeForLabel(width: textWidth, maxLines: data.descriptionLineLimit)
//            : nil
        
        
//        var imageFrame: CGRect?
//        var hostFrame: CGRect?
//        var titleFrame: CGRect?
//        var descriptionFrame: CGRect?
//        
//        var nextItemMaxY: CGFloat = 0
//        
//        if let imageSize {
//            imageFrame = CGRect(origin: .zero, size: imageSize)
//            nextItemMaxY += (imageSize.height + textInsets.top)
//        } else {
//            nextItemMaxY += textInsets.top
//        }
//        
//        if let hostSize {
//            hostFrame = CGRect(origin: CGPoint(x: textInsets.left, y: nextItemMaxY), size: hostSize)
//            nextItemMaxY += (hostSize.height + spacingBetweenText)
//        }
//        
//        if let titleSize {
//            titleFrame = CGRect(origin: CGPoint(x: textInsets.left, y: nextItemMaxY), size: titleSize)
//            nextItemMaxY += (titleSize.height + spacingBetweenText)
//        }
//        
//        if let descriptionSize {
//            descriptionFrame = CGRect(origin: CGPoint(x: textInsets.left, y: nextItemMaxY), size: descriptionSize)
//        }
//        
//        let height = max(imageFrame?.maxY ?? 0, hostFrame?.maxY ?? 0, titleFrame?.maxY ?? 0, descriptionFrame?.maxY ?? 0) + textInsets.bottom
//        
//        let size = CGSize(width: targetSize.width, height: height)
        
        return MessageBigBookmarkLayout(
            size: size ?? .zero,
            imageFrame: imageFrame,
            hostFrame: hostFrame,
            titleFrame: titleFrame,
            descriptionFrame: descriptionFrame
        )
    }
}
