import Foundation
import UIKit

struct MessageBubbleLayout: Equatable {
    let bubbleSize: CGSize
    let textFrame: CGRect?
    let textLayout: MessageTextLayout?
    let gridAttachmentsFrame: CGRect?
    let gridAttachmentsLayout: MessageGridAttachmentsContainerLayout?
}

struct MessageBubbleCalculator {
    
    static func calculateSize(targetSize: CGSize, message: NSAttributedString, linkedObjects: MessageLinkedObjectsLayout?) -> MessageBubbleLayout {
        
        let width = targetSize.width
        let gridInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        let textInset = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        
        var gridLayout: MessageGridAttachmentsContainerLayout?
        var gridFrame: CGRect?
        var topContainerSize: CGSize = .zero
        
        switch linkedObjects {
        case .list, .none:
            topContainerSize = CGSize(width: 0, height: 4)
        case .grid(let attachments):
            if attachments.isNotEmpty {
                let size = CGSize(
                    width: width - gridInset.left - gridInset.right,
                    height: .greatestFiniteMagnitude
                )
                
                let gridCalculatedLayout = MessageGridAttachmentsCaluculator.calculateSize(targetSize: size, attachments: attachments)
                gridLayout = gridCalculatedLayout
                let gridCalculatedFrame = CGRect(
                    origin: CGPointMake(gridInset.top, gridInset.left),
                    size: gridCalculatedLayout.size
                )
                gridFrame = gridCalculatedFrame
                topContainerSize = gridCalculatedFrame.inset(by: gridInset.inverted).size
            }
        case .bookmark(let objectDetails):
            // TODO: Implement
            break
        }
        
        var bottomContainerSize: CGSize = .zero
        switch linkedObjects {
        case .list(let array):
            // TODO: Implement
            break
        case .grid, .bookmark, .none:
            bottomContainerSize = CGSize(width: 0, height: 4)
        }
        
        var textLayout: MessageTextLayout?
        var textFrame: CGRect?
        var textContainerSize: CGSize = .zero
        if !message.string.isEmpty {
            let size = CGSize(
                width: width - textInset.left - textInset.right,
                height: .greatestFiniteMagnitude
            )
            let textCalculatedLayout = MessageTextCalculator.calculateSize(targetSize: size, message: message)
            textLayout = textCalculatedLayout
            let textCalculatedFrame = CGRect(
                origin: CGPoint(x: textInset.left, y: textInset.top + topContainerSize.height),
                size: textCalculatedLayout.size
            )
            textFrame = textCalculatedFrame
            textContainerSize = textCalculatedFrame.inset(by: textInset.inverted).size
        }
        
        let bubleSize = CGSize(
            width: max(topContainerSize.width, textContainerSize.width, bottomContainerSize.width),
            height: topContainerSize.height + textContainerSize.height + bottomContainerSize.height
        )
        
        return MessageBubbleLayout(
            bubbleSize: bubleSize,
            textFrame: textFrame,
            textLayout: textLayout,
            gridAttachmentsFrame: gridFrame,
            gridAttachmentsLayout: gridLayout
        )
    }
}
