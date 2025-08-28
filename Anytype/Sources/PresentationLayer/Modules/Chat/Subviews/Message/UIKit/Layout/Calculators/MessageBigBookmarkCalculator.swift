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
        
        return MessageBigBookmarkLayout(
            size: size ?? .zero,
            imageFrame: imageFrame,
            hostFrame: hostFrame,
            titleFrame: titleFrame,
            descriptionFrame: descriptionFrame
        )
    }
}
