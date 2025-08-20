import Foundation
import UIKit

struct MessageBubbleLayout: Equatable {
    let bubbleSize: CGSize
    let textFrame: CGRect?
    let textLayout: MessageTextLayout?
}

struct MessageBubbleCalculator {
    
    static func calculateSize(targetSize: CGSize, message: NSAttributedString) -> MessageBubbleLayout {
        
        let width = targetSize.width
        let textInset = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        
        let textIsEmpty = message.string.isEmpty
        
        var textLayout: MessageTextLayout?
        if !textIsEmpty {
            let size = CGSize(
                width: width - textInset.left - textInset.right,
                height: .greatestFiniteMagnitude
            )
            textLayout = MessageTextCalculator.calculateSize(targetSize: size, message: message)
        }
        
        let textFrame = CGRect(
            origin: CGPoint(x: textInset.left, y: textInset.top),
            size: textLayout?.size ?? .zero
        )
        
        let textContainerSize = textFrame.inset(by: textInset.inverted).size
        
        return MessageBubbleLayout(
            bubbleSize: textContainerSize,
            textFrame: textIsEmpty ? nil : textFrame,
            textLayout: textLayout
        )
    }
}
