import Foundation

struct MessageListAttachmentsCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageListAttachmentsViewData) -> MessageListAttachmentsLayout {
        
        var frames: [CGRect] = []
        var size: CGSize?
        
        VStackCalculator(spacing: 4) {
            for object in data.objects {
                switch object.resolvedLayoutValue {
                case .bookmark:
                    AnyViewCalculator { targetSize in
                        CGSize(width: targetSize.width, height: MessageBookmarkLayout.height)
                    }
                    .readFrame { frames.append($0) }
                default:
                    AnyViewCalculator { targetSize in
                        CGSize(width: targetSize.width, height: MessageObjectLayout.height)
                    }
                    .readFrame { frames.append($0) }
                }
            }
        }
        .readFrame { size = $0.size }
        .calculate(targetSize)
        
        return MessageListAttachmentsLayout(size: size ?? .zero, objectFrames: frames)
    }
}
