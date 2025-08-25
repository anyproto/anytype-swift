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
        
        HStackCauculator(alignment: .bottom, spacing: 6, frameWriter: { calculatedSize = $0.size }) {
            if let iconSize {
                AnyViewCalculator(size: iconSize, frameWriter: { iconFrame = $0 })
            }
            AnyViewCalculator(size: bubbleLayout.bubbleSize, frameWriter: { bubbleFrame = $0 })
        }
        .calculate()
        
//        // Layout Main Vertical
//        var currentYForMainContent: CGFloat = 0
//        
//        if bubbleLayout.bubbleSize.isNotZero {
//            bubbleFrame = CGRect(
//                origin: .zero,
//                size: bubbleLayout.bubbleSize
//            )
//            currentYForMainContent += bubbleLayout.bubbleSize.height + verticalSpacing
//        }
//        
//        if reactionsData.showReactions {
//            reactionsFrame = CGRect(
//                origin: CGPoint(x: 0, y: currentYForMainContent),
//                size: reactionsLayout.size
//            )
//            currentYForMainContent += bubbleLayout.bubbleSize.height + verticalSpacing
//        }
//        
//        let yForImage = max(bubbleFrame?.maxY ?? 0, reactionsFrame?.maxY ?? 0)
//        
//        
//        
//        
//        let bubbleSize = bubbleLayout.bubbleSize
//        
//        let calculatedSize = CGSize(
//            width: iconWidth + bubbleSize.width + spacingForOtherSize + containerInsets.left + containerInsets.right,
//            height: bubbleSize.height + containerInsets.top + containerInsets.bottom
//        )
//        
//        var freeContentFrame = CGRect(origin: .zero, size: size)
//        freeContentFrame = freeContentFrame.inset(by: containerInsets)
//        
//        if data.position.isRight {
//            if let iconSize {
//                iconFrame = CGRect(
//                    origin: CGPoint(x: freeContentFrame.maxX - iconSize.width, y: freeContentFrame.maxY - iconSize.height),
//                    size: iconSize
//                )
//            }
//            
//            if let iconFrame {
//                freeContentFrame = freeContentFrame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: iconFrame.width + spacingBetweenIconAndText))
//            }
//            
//            if bubbleSize.isNotZero {
//                bubbleFrame = CGRect(
//                    origin: CGPoint(x: freeContentFrame.maxX - bubbleSize.width, y: freeContentFrame.maxY - bubbleSize.height),
//                    size: bubbleSize
//                )
//            }
//            
//            if reactionsData.showReactions {
//                
//            }
//            
//        } else {
//            
//            if let iconSize {
//                iconFrame = CGRect(
//                    origin: CGPoint(x: freeContentFrame.minX, y: freeContentFrame.maxY - iconSize.height),
//                    size: iconSize
//                )
//            }
//            
//            if let iconFrame {
//                freeContentFrame = freeContentFrame.inset(by: UIEdgeInsets(top: 0, left: iconFrame.width + spacingBetweenIconAndText, bottom: 0, right: 0))
//            }
//            
//            if bubbleSize.isNotZero {
//                bubbleFrame = CGRect(
//                    origin: CGPoint(x: freeContentFrame.minX, y: freeContentFrame.minY),
//                    size: bubbleSize
//                )
//            }
//        }
        
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
