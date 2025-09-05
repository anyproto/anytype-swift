import Foundation

struct MessageReactionsListCalculator {
    
    let reactionCalculator = MessageReactionCalculator()
    
    func calculateSize(targetSize: CGSize, data: MessageReactionListData) -> MessageReactionListLayout {
        
        let horizontalSpacing: CGFloat = 8
        let verticalSpacing: CGFloat = 8
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        var reactionFrames = [CGRect]()
        var reactionLayouts = [MessageReactionLayout]()
        
        for reaction in data.reactions {
            let layout = reactionCalculator.calculateSize(targetSize: targetSize, data: reaction)
            
            if (currentX + layout.size.width) > targetSize.width {
                currentY += (layout.size.height + verticalSpacing)
                currentX = 0
            }
            let frame = CGRect(
                origin: CGPoint(x: currentX, y: currentY),
                size: layout.size
            )
            reactionFrames.append(frame)
            reactionLayouts.append(layout)
            maxWidth = max(maxWidth, currentX + layout.size.width)
            maxHeight = max(maxHeight, currentY + layout.size.height)
            currentX += (layout.size.width + horizontalSpacing)
        }
        
        var addReactionFrame: CGRect?
        
        if data.canAddReaction {
            let size = MessageReactionListLayout.addReactionSize
            
            if (currentX + size.width) > targetSize.width {
                currentY += (size.height + verticalSpacing)
                currentX = 0
            }
            
            addReactionFrame = CGRect(
                origin: CGPoint(x: currentX, y: currentY),
                size: size
            )
            
            maxWidth = max(maxWidth, currentX + size.width)
            maxHeight = max(maxHeight, currentY + size.height)
        }
        
        return MessageReactionListLayout(
            size: CGSize(width: maxWidth, height: maxHeight),
            reactionFrames: reactionFrames,
            reactionLayouts: reactionLayouts,
            addReactionFrame: addReactionFrame
        )
    }
}
