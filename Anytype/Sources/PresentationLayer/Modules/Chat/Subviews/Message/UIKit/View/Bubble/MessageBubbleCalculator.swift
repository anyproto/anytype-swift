import Foundation
import UIKit

struct MessageBubbleCalculator {
    
    private enum Constants {
        static let attachmentsPadding: CGFloat = 4
        static let messageHorizontalPadding: CGFloat = 12
    }
    
    static func calculateSize(targetSize: CGSize, data: MessageBubbleViewData) -> MessageBubbleLayout {
        
        var gridLayout: MessageGridAttachmentsContainerLayout?
        var gridFrame: CGRect?
        var bigBookmarkLayout: MessageBigBookmarkLayout?
        var bigBookmarkFrame: CGRect?
        
        var textLayout: MessageTextLayout?
        var textFrame: CGRect?
        
        var listLayout: MessageListAttachmentsLayout?
        var listFrame: CGRect?
        
        var bubbleSize: CGSize = .zero
        
        VStackCalculator(alignment: .left) {
            
            // Top Attachments
            
            switch data.linkedObjects {
            case .list, .none:
                if data.messageData.isNotNil {
                    AnyViewCalculator(size: CGSize(width: 0, height: Constants.attachmentsPadding))
                }
            case .grid(let attachments):
                AnyViewCalculator { targetSize in
                    let layout = MessageGridAttachmentsCaluculator.calculateSize(targetSize: targetSize, attachments: attachments)
                    gridLayout = layout
                    return layout.size
                }
                .readFrame { gridFrame = $0 }
                .padding(Constants.attachmentsPadding)
            case .bookmark(let data):
                AnyViewCalculator { targetSize in
                    let layout = MessageBigBookmarkCalculator.calculateSize(targetSize: targetSize, data: data)
                    bigBookmarkLayout = layout
                    return layout.size
                }
                .readFrame { bigBookmarkFrame = $0 }
                .padding(Constants.attachmentsPadding)
            }
            
            // Text
            
            if let messageData = data.messageData {
                AnyViewCalculator { targetSize in
                    let layout = MessageTextCalculator.calculateSize(targetSize: targetSize, data: messageData, useTargetSizeForInfo: data.linkedObjects.isNotNil)
                    textLayout = layout
                    return layout.size
                }
                .readFrame { textFrame = $0 }
                .padding(horizontal: 12, vertical: 4)
            }
            
            // Bottom Attachments
            
            switch data.linkedObjects {
            case .list(let data):
                AnyViewCalculator { targetSize in
                    let layout = MessageListAttachmentsCalculator.calculateSize(targetSize: targetSize, data: data)
                    listLayout = layout
                    return layout.size
                }
                .readFrame { listFrame = $0 }
                .padding(Constants.attachmentsPadding)
            case .grid, .bookmark, .none:
                if data.messageData.isNotNil {
                    AnyViewCalculator(size: CGSize(width: 0, height: Constants.attachmentsPadding))
                }
            }
        }
        .readFrame { bubbleSize = $0.size }
        .calculate(targetSize)
        
        return MessageBubbleLayout(
            bubbleSize: bubbleSize,
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
