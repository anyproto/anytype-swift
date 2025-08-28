import Foundation
import Cache
import UIKit
import os

final class MessageLayoutCalculator {
    
    private let lock = OSAllocatedUnfairLock()
    private let cache: MemoryStorage<Int, MessageLayout> = {
        let config = MemoryConfig(countLimit: 10000)
        return MemoryStorage<Int, MessageLayout>(config: config)
    }()
    
    func makeLayout(targetSize: CGSize, data: MessageViewData) -> MessageLayout {
        
        lock.lock()
        defer { lock.unlock() }
        
        if let cacheValue = try? cache.object(forKey: data.hashValue) {
            return cacheValue
        }
        
        let layout = makeRootLayout(size: targetSize, data: data)
        
        cache.setObject(layout, forKey: data.hashValue)
        
        return layout
    }
    
    // MARK: - Private
    
    private func makeRootLayout(size: CGSize, data: MessageViewData) -> MessageLayout {
        let containerInsets = UIEdgeInsets(top: 0, left: 14, bottom: data.nextSpacing.height, right: 14)
        let iconSide: CGFloat = 32
        
        // Icon
        
        var iconFrame: CGRect?
        let authorIcon: (any ViewCalculator)?
        switch data.authorIconMode {
        case .show:
            authorIcon = AnyViewCalculator(size: CGSize(width: iconSide, height: iconSide), frameWriter: { iconFrame = $0 }).layoutPriority(1)
        case .empty:
            authorIcon = AnyViewCalculator(size: CGSize(width: iconSide, height: iconSide), frameWriter: { _ in }).layoutPriority(1)
        case .hidden:
            authorIcon = nil
        }
        
        // Spacing icon for other size
        let bubbleSpacing = AnyViewCalculator(size: CGSize(width: 26, height: 0), frameWriter: { _ in }).layoutPriority(1)
        
        // Bubble
        
        var bubbleFrame: CGRect?
        var bubbleLayout: MessageBubbleLayout?
        let bubbleCalculator = AnyViewCalculator { targetSize in
            let layout = MessageBubbleCalculator.calculateSize(targetSize: targetSize, data: MessageBubbleViewData(data: data))
            bubbleLayout = layout
            return layout.bubbleSize
        } frameWriter: {
            bubbleFrame = $0
        }

        // Reactions
        
        let reactionsData = MessageReactionListData(data: data)
        var reactionsFrame: CGRect?
        var reactionsLayout: MessageReactionListLayout?
        let reactionsCalculator = reactionsData.showReactions
            ? AnyViewCalculator { targetSize in
                let layout = MessageReactionsListCalculator.calculateSize(targetSize: targetSize, data: reactionsData)
                reactionsLayout = layout
                return layout.size
            } frameWriter: {
                reactionsFrame = $0
            }
            : nil
        
        // Final
        
        let hStack = HStackCauculator(alignment: .bottom, spacing: 6, frameWriter: { _ in }) {
            if data.position.isLeft {
                authorIcon
            } else {
                bubbleSpacing
            }
            VStackCalculator(alignment: data.position.isLeft ? .left : .right, spacing: 4) {
                bubbleCalculator
                reactionsCalculator
            }
            if data.position.isRight {
                authorIcon
            } else {
                bubbleSpacing
            }
        }
            .insets(containerInsets)
        
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
            reactionsLayout: reactionsLayout
        )
    }
}
