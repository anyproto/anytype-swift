import Foundation
import UIKit

struct MessageReplyCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageReplyViewData) -> MessageReplyLayout {
        
        var size: CGSize?
        var authorFrame: CGRect?
        var iconFrame: CGRect?
        var descriptionFrame: CGRect?
        
        VStackCalculator(alignment: .left, spacing: 2) {
            
            AnyViewCalculator { targetSize in
                data.author.sizeForLabel(width: targetSize.width, maxLines: 1)
            }
            .padding(horizontal: 16)
            .readFrame { authorFrame = $0 }
            
            HStackCauculator(spacing: 6) {
                
                if data.attachmentIcon.isNotNil {
                    AnyViewCalculator(size: CGSize(width: 16, height: 16))
                        .readFrame { iconFrame = $0 }
                }
                
                AnyViewCalculator { targetSize in
                    data.description.sizeForLabel(
                        width: targetSize.width,
                        maxLines: data.attachmentIcon.isNotNil ? 1 : 3
                    )
                }
                .readFrame { descriptionFrame = $0 }
            }
        }
        .padding(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 8))
        .readFrame { size = $0.size }
        .calculate(targetSize)
        
        return MessageReplyLayout(
            size: size ?? .zero,
            authorFrame: authorFrame,
            iconFrame: iconFrame,
            descriptionFrame: descriptionFrame
        )
    }
}
