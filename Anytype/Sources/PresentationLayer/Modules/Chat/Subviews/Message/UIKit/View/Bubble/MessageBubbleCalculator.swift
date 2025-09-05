import Foundation
import UIKit

struct MessageBubbleCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageBubbleViewData) -> MessageBubbleLayout {
        
        let width = targetSize.width
        let attachmentsInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        var textInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        let attachmentsSize = CGSize(
            width: width - attachmentsInsets.left - attachmentsInsets.right,
            height: .greatestFiniteMagnitude
        )
        
        var gridLayout: MessageGridAttachmentsContainerLayout?
        var gridFrame: CGRect?
        var bigBookmarkLayout: MessageBigBookmarkLayout?
        var bigBookmarkFrame: CGRect?
        var topContainerSize: CGSize = .zero
        
        switch data.linkedObjects {
        case .list, .none:
            break
        case .grid(let attachments):
            if attachments.isNotEmpty {
                let gridCalculatedLayout = MessageGridAttachmentsCaluculator.calculateSize(targetSize: attachmentsSize, attachments: attachments)
                gridLayout = gridCalculatedLayout
                let gridCalculatedFrame = CGRect(
                    origin: CGPointMake(attachmentsInsets.top, attachmentsInsets.left),
                    size: gridCalculatedLayout.size
                )
                gridFrame = gridCalculatedFrame
                topContainerSize = gridCalculatedFrame.inset(by: attachmentsInsets.inverted).size
            }
            textInset.top -= 4
        case .bookmark(let data):
            let bookmarkCalculatedLayout = MessageBigBookmarkCalculator.calculateSize(targetSize: attachmentsSize, data: data)
            bigBookmarkLayout = bookmarkCalculatedLayout
            let bookmarkCalculatedFrame = CGRect(
                origin: CGPoint(x: attachmentsInsets.left, y: attachmentsInsets.top),
                size: bookmarkCalculatedLayout.size
            )
            bigBookmarkFrame = bookmarkCalculatedFrame
            topContainerSize = bookmarkCalculatedFrame.inset(by: attachmentsInsets.inverted).size
            textInset.top -= 4
        }
        
        var textLayout: MessageTextLayout?
        var textFrame: CGRect?
        var textContainerSize: CGSize = .zero
        if let messageData = data.messageData {
            let size = CGSize(
                width: width - textInset.left - textInset.right,
                height: .greatestFiniteMagnitude
            )
            let textCalculatedLayout = MessageTextCalculator.calculateSize(targetSize: size, data: messageData)
            textLayout = textCalculatedLayout
            let textCalculatedFrame = CGRect(
                origin: CGPoint(x: textInset.left, y: textInset.top + topContainerSize.height),
                size: textCalculatedLayout.size
            )
            textFrame = textCalculatedFrame
            textContainerSize = textCalculatedFrame.inset(by: textInset.inverted).size
        }
        
        var bottomContainerSize: CGSize = .zero
        var listLayout: MessageListAttachmentsLayout?
        var listFrame: CGRect?
        switch data.linkedObjects {
        case .list(let data):
            let listCalculatedLayout = MessageListAttachmentsCalculator.calculateSize(targetSize: attachmentsSize, data: data)
            listLayout = listCalculatedLayout
            let listCalculatedFrame = CGRect(
                origin: CGPoint(x: attachmentsInsets.left, y: attachmentsInsets.top + topContainerSize.height + textContainerSize.height),
                size: listCalculatedLayout.size
            )
            listFrame = listCalculatedFrame
            bottomContainerSize = listCalculatedFrame.inset(by: attachmentsInsets.inverted).size
            textInset.bottom -= 4
        case .grid, .bookmark, .none:
            break
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
            bigBookmarkLayout: bigBookmarkLayout,
            listAttachmentsFrame: listFrame,
            listAttachmentsLayout: listLayout
        )
    }
}
