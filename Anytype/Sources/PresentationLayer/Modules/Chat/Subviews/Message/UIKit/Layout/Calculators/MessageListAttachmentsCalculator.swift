import Foundation

struct MessageListAttachmentsCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageListAttachmentsViewData) -> MessageListAttachmentsLayout {
        
        var currentY: CGFloat = 0
        var frames: [CGRect] = []
        
        for object in data.objects {
            switch object.resolvedLayoutValue {
            case .bookmark:
                let frame = CGRect(x: 0, y: currentY, width: targetSize.width, height: MessageBookmarkLayout.height)
                frames.append(frame)
                currentY += frame.height + 4
            default:
                let frame = CGRect(x: 0, y: currentY, width: targetSize.width, height: MessageObjectLayout.height)
                frames.append(frame)
                currentY += frame.height + 4
            }
        }
        
        let size = CGSize(width: targetSize.width, height: frames.last?.maxY ?? 0)
        return MessageListAttachmentsLayout(size: size, objectFrames: frames)
    }
}
