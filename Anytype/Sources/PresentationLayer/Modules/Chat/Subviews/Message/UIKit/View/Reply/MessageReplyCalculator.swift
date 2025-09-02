import Foundation
import UIKit

struct MessageReplyCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageReplyViewData) -> MessageReplyLayout {
        
        var size: CGSize = .zero
        var lineFrame: CGRect?
        var backgroundFrame: CGRect?
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
            .padding(8)
            .readFrame { backgroundFrame = $0 }
        }
        .padding(left: 8) // Padding for vertical line
        .readFrame { size = $0.size }
        .calculate(targetSize)
        
        if let backgroundFrame {
            lineFrame = CGRect(x: 0, y: backgroundFrame.minY, width: 4, height: backgroundFrame.height)
        }
        
        return MessageReplyLayout(
            size: size,
            lineFrame: lineFrame,
            backgroundFrame: backgroundFrame,
            authorFrame: authorFrame,
            iconFrame: iconFrame,
            descriptionFrame: descriptionFrame
        )
    }
}
