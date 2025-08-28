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
        
//        cache.setObject(layout, forKey: data.hashValue)
        
        return layout
    }
    
    // MARK: - Private
    
    private func makeRootLayout(size: CGSize, data: MessageViewData) -> MessageLayout {
        let containerInsets = UIEdgeInsets(top: 0, left: 14, bottom: data.nextSpacing.height, right: 14)
        let iconSide: CGFloat = 32
        let spacingBetweenIconAndText: CGFloat = 6
        let spacingForOtherSize: CGFloat = 26
        let verticalSpacing: CGFloat = 6
        
        let showIcon: Bool
        let iconSize: CGSize?
        switch data.authorIconMode {
        case .show:
            iconSize = CGSize(width: iconSide, height: iconSide)
            showIcon = true
        case .empty:
            iconSize = CGSize(width: iconSide, height: iconSide)
            showIcon = false
        case .hidden:
            iconSize = nil
            showIcon = false
        }
        
        
        let iconWidth = iconSize.map { $0.width + spacingBetweenIconAndText } ?? 0
        let mainContentSize = CGSize(
            width: size.width - iconWidth - spacingForOtherSize - containerInsets.left - containerInsets.right,
            height: .greatestFiniteMagnitude
        )
        
        let bubbleLayout = MessageBubbleCalculator.calculateSize(targetSize: mainContentSize, data: MessageBubbleViewData(data: data))
        let reactionsData = MessageReactionListData(data: data)
        let reactionsLayout = MessageReactionsListCalculator.calculateSize(targetSize: mainContentSize, data: reactionsData)
        
        var iconFrame: CGRect?
        var bubbleFrame: CGRect?
        var reactionsFrame: CGRect?
        var calculatedSize: CGSize?
        
        let authorIcon: (any ViewCalculator)?
        switch data.authorIconMode {
        case .show:
            authorIcon = AnyViewCalculator(size: CGSize(width: iconSide, height: iconSide), frameWriter: { iconFrame = $0 }).layoutPriority(1)
        case .empty:
            authorIcon = AnyViewCalculator(size: CGSize(width: iconSide, height: iconSide), frameWriter: { _ in }).layoutPriority(1)
        case .hidden:
            authorIcon = nil
        }
        
        let bubbleSpacing = AnyViewCalculator(size: CGSize(width: 32, height: 0), frameWriter: { _ in }).layoutPriority(1)
        
        let hStack = HStackCauculator(alignment: .bottom, spacing: 6, frameWriter: { calculatedSize = $0.size }) {
            if data.position.isLeft {
                authorIcon
            } else {
                bubbleSpacing
            }
            AnyViewCalculator(size: bubbleLayout.bubbleSize, frameWriter: { bubbleFrame = $0 })
            if data.position.isRight {
                authorIcon
            } else {
                bubbleSpacing
            }
        }
        
        var hStackFrame = CGRect(origin: .zero, size: hStack.sizeThatFits(size))
        
        // Pin to right
        if data.position.isRight {
            hStackFrame = hStackFrame.offsetBy(dx: size.width - hStackFrame.width, dy: 0)
        }
        
        hStack.setFrame(hStackFrame)
        
        calculatedSize = CGSize(width: size.width, height: hStackFrame.height)
        
        return MessageLayout(
            cellSize: calculatedSize ?? .zero,
            iconFrame: showIcon ? iconFrame : nil,
            bubbleFrame: bubbleFrame,
            bubbleLayout: bubbleLayout,
            reactionsFrame: nil,
            reactionsLayout: nil
        )
    }
}
