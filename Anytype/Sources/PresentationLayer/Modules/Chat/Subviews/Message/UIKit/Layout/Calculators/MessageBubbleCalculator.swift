import Foundation
import UIKit

struct MessageBubbleLayout: Equatable {
    let bubbleSize: CGSize
    let textFrame: CGRect?
    let textLayout: MessageTextLayout?
    let gridAttachmentsFrame: CGRect?
    let gridAttachmentsLayout: MessageGridAttachmentsContainerLayout?
    let bigBookmarkFrame: CGRect?
    let bigBookmarkLayout: MessageBigBookmarkLayout?
}

struct MessageBubbleCalculator {
    
    static func calculateSize(targetSize: CGSize, message: NSAttributedString, linkedObjects: MessageLinkedObjectsLayout?, position: MessageHorizontalPosition) -> MessageBubbleLayout {
        
        let width = targetSize.width
        let attachmentsInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        var textInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        var gridLayout: MessageGridAttachmentsContainerLayout?
        var gridFrame: CGRect?
        var bigBookmarkLayout: MessageBigBookmarkLayout?
        var bigBookmarkFrame: CGRect?
        var topContainerSize: CGSize = .zero
        
        switch linkedObjects {
        case .list, .none:
            break
        case .grid(let attachments):
            if attachments.isNotEmpty {
                let size = CGSize(
                    width: width - attachmentsInsets.left - attachmentsInsets.right,
                    height: .greatestFiniteMagnitude
                )
                
                let gridCalculatedLayout = MessageGridAttachmentsCaluculator.calculateSize(targetSize: size, attachments: attachments)
                gridLayout = gridCalculatedLayout
                let gridCalculatedFrame = CGRect(
                    origin: CGPointMake(attachmentsInsets.top, attachmentsInsets.left),
                    size: gridCalculatedLayout.size
                )
                gridFrame = gridCalculatedFrame
                topContainerSize = gridCalculatedFrame.inset(by: attachmentsInsets.inverted).size
            }
            textInset.top -= 4
        case .bookmark(let objectDetails):
            let size = CGSize(
                width: width - attachmentsInsets.left - attachmentsInsets.right,
                height: .greatestFiniteMagnitude
            )
            let data = MessageBigBookmarkViewData(details: objectDetails, position: position)
            let bookmarkCalculatedLayout = MessageBigBookmarkCalculator.calculateSize(targetSize: size, data: data)
            bigBookmarkLayout = bookmarkCalculatedLayout
            let bookmarkCalculatedFrame = CGRect(
                origin: CGPointMake(attachmentsInsets.top, attachmentsInsets.left),
                size: bookmarkCalculatedLayout.size
            )
            bigBookmarkFrame = bookmarkCalculatedFrame
            topContainerSize = bookmarkCalculatedFrame.inset(by: attachmentsInsets.inverted).size
            textInset.top -= 4
        }
        
        var bottomContainerSize: CGSize = .zero
        switch linkedObjects {
        case .list(let array):
            // TODO: Implement
            break
            textInset.bottom -= 4
        case .grid, .bookmark, .none:
            break
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
            gridAttachmentsLayout: gridLayout,
            bigBookmarkFrame: bigBookmarkFrame,
            bigBookmarkLayout: bigBookmarkLayout
        )
    }
}
