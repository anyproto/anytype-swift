import Foundation
import UIKit

struct MessageReactionCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageReactionData) -> MessageReactionLayout {
        
        let insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let spacing: CGFloat = 4
        
        let height = MessageReactionLayout.height
        let textWidth = targetSize.width - insets.left - insets.right
        
        let emojiSize = data.emojiAttributedString.sizeForLabel(width: textWidth)
        let emojiFrame = CGRect(
            origin: CGPoint(x: insets.left, y: (height - emojiSize.height) * 0.5),
            size: emojiSize
        )
        
        var countFrame: CGRect?
        var iconFrame: CGRect?
        
        switch data.content {
        case .count(let int):
            let countSize = data.countAttributedString?.sizeForLabel(width: textWidth) ?? .zero
            countFrame = CGRect(
                origin: CGPoint(x: emojiFrame.maxX + spacing, y: (height - countSize.height) * 0.5),
                size: countSize
            )
        case .icon(let icon):
            iconFrame = CGRect(
                origin: CGPoint(x: emojiFrame.maxX + spacing, y: (height - MessageReactionLayout.iconSize.height) * 0.5),
                size: MessageReactionLayout.iconSize
            )
        }
        
        let size = CGSize(
            width: max(emojiFrame.maxX, countFrame?.maxX ?? 0, iconFrame?.maxX ?? 0) + insets.right,
            height: height
        )
        
        return MessageReactionLayout(
            size: size,
            emojiFrame: emojiFrame,
            countFrame: countFrame,
            iconFrme: iconFrame
        )
    }
}
