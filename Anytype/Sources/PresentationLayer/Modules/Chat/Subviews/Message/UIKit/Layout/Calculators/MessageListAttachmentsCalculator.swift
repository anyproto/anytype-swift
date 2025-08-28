import Foundation

struct MessageListAttachmentsCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageListAttachmentsViewData) -> MessageListAttachmentsLayout {
        
        var frames: [CGRect] = []
        var size: CGSize?
        
        VStackCalculator(spacing: 4, frameWriter: { size = $0.size }) {
            for object in data.objects {
                switch object.resolvedLayoutValue {
                case .bookmark:
                    AnyViewCalculator { targetSize in
                        CGSize(width: targetSize.width, height: MessageBookmarkLayout.height)
                    } frameWriter: { frame in
                        frames.append(frame)
                    }
                default:
                    AnyViewCalculator { targetSize in
                        CGSize(width: targetSize.width, height: MessageObjectLayout.height)
                    } frameWriter: { frame in
                        frames.append(frame)
                    }
                }
            }
        }
        .calculate(targetSize)
        
        return MessageListAttachmentsLayout(size: size ?? .zero, objectFrames: frames)
    }
}
