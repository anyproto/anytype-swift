import Foundation
import UIKit

struct MessageReactionCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageReactionData) -> MessageReactionLayout {
        
        var size: CGSize?
        var emojiFrame: CGRect?
        var countFrame: CGRect?
        var iconFrame: CGRect?
        
        HStackCauculator(spacing: 4, frameWriter: { size = $0.size }) {
            AnyViewCalculator { targetSize in
                return data.emojiAttributedString.sizeForLabel(width: targetSize.width)
            } frameWriter: {
                emojiFrame = $0
            }
            
            switch data.content {
            case .count(let int):
                AnyViewCalculator { targetSize in
                    return data.countAttributedString?.sizeForLabel(width: targetSize.width) ?? .zero
                } frameWriter: {
                    countFrame = $0
                }
            case .icon(let icon):
                AnyViewCalculator { _ in
                    return MessageReactionLayout.iconSize
                } frameWriter: {
                    iconFrame = $0
                }
            }
        }
        .frame(height: MessageReactionLayout.height)
        .padding(horizontal: 8)
        .calculate(targetSize)
        
        return MessageReactionLayout(
            size: size ?? .zero,
            emojiFrame: emojiFrame ?? .zero,
            countFrame: countFrame,
            iconFrme: iconFrame
        )
    }
}
