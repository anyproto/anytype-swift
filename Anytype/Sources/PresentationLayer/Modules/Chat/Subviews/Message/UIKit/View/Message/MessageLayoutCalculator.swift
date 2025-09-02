import Foundation
import Cache
import UIKit
import os

final class MessageLayoutCalculator: @unchecked Sendable {
    
    private let lock = OSAllocatedUnfairLock()
    private let cache: MemoryStorage<Int, MessageLayout> = {
        let config = MemoryConfig(countLimit: 10000)
        return MemoryStorage<Int, MessageLayout>(config: config)
    }()
    
    func makeLayout(width: CGFloat, data: MessageViewData) -> MessageLayout {
        
        lock.lock()
        defer { lock.unlock() }
        
        if let cacheValue = try? cache.object(forKey: data.hashValue) {
            return cacheValue
        }
        
        let layout = makeRootLayout(width: width, data: data)
        
        cache.setObject(layout, forKey: data.hashValue)
        
        return layout
    }
    
    func prepareLayout(width: CGFloat, data: MessageViewData) {
        _ = makeLayout(width: width, data: data)
    }
    
    // MARK: - Private
    
    private func makeRootLayout(width: CGFloat, data: MessageViewData) -> MessageLayout {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let containerInsets = UIEdgeInsets(top: 0, left: 14, bottom: data.nextSpacing.height, right: 14)
        let iconSide: CGFloat = 32
        
        // Icon
        
        var iconFrame: CGRect?
        let authorIcon: (any ViewCalculator)?
        switch data.authorIconMode {
        case .show:
            authorIcon = AnyViewCalculator(size: CGSize(width: iconSide, height: iconSide))
                .layoutPriority(1)
                .readFrame { iconFrame = $0 }
        case .empty:
            authorIcon = AnyViewCalculator(size: CGSize(width: iconSide, height: iconSide)).layoutPriority(1)
        case .hidden:
            authorIcon = nil
        }
        
        // Spacing icon for other size
        let bubbleSpacing = AnyViewCalculator(size: CGSize(width: 26, height: 0)).layoutPriority(1)
        
        // Bubble
        
        var bubbleFrame: CGRect?
        var bubbleLayout: MessageBubbleLayout?
        let bubbleCalculator = AnyViewCalculator { targetSize in
            let layout = MessageBubbleCalculator.calculateSize(targetSize: targetSize, data: MessageBubbleViewData(data: data))
            bubbleLayout = layout
            return layout.bubbleSize
        }
        .readFrame { bubbleFrame = $0 }
        
        // Reactions
        
        let reactionsData = MessageReactionListData(data: data)
        var reactionsFrame: CGRect?
        var reactionsLayout: MessageReactionListLayout?
        let reactionsCalculator = reactionsData.showReactions
            ? AnyViewCalculator { targetSize in
                let layout = MessageReactionsListCalculator.calculateSize(targetSize: targetSize, data: reactionsData)
                reactionsLayout = layout
                return layout.size
            }
            .readFrame { reactionsFrame = $0 }
            : nil
        
        // Reply
        
        var replyFrame: CGRect?
        var replyLayout: MessageReplyLayout?
        let replyData = data.replyModel.map { MessageReplyViewData(model: $0) }
        
        // Final
        
        let hStack = HStackCauculator(alignment: .bottom, spacing: 6) {
            if data.position.isLeft {
                authorIcon
            } else {
                bubbleSpacing
            }
            VStackCalculator(alignment: data.position.isLeft ? .left : .right, spacing: 4) {
                
                if let replyData {
                    AnyViewCalculator { targetSize in
                        let layout = MessageReplyCalculator.calculateSize(targetSize: targetSize, data: replyData)
                        replyLayout = layout
                        return layout.size
                    }
                    .readFrame { replyFrame = $0 }
                }
                
                bubbleCalculator
                reactionsCalculator
            }
            if data.position.isRight {
                authorIcon
            } else {
                bubbleSpacing
            }
        }
        .padding(containerInsets)
        
        var hStackFrame = CGRect(origin: .zero, size: hStack.sizeThatFits(size))
        
        // Pin to right
        if data.position.isRight {
            hStackFrame = hStackFrame.offsetBy(dx: size.width - hStackFrame.width, dy: 0)
        }
        
        hStack.setFrame(hStackFrame)
        
        let calculatedSize = CGSize(width: size.width, height: hStackFrame.height)
        
        return MessageLayout(
            cellSize: calculatedSize,
            iconFrame: iconFrame,
            bubbleFrame: bubbleFrame,
            bubbleLayout: bubbleLayout,
            reactionsFrame: reactionsFrame,
            reactionsLayout: reactionsLayout,
            replyFrame: replyFrame,
            replyLayout: replyLayout
        )
    }
}
