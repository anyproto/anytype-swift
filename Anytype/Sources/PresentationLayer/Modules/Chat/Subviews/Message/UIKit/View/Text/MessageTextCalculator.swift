import Foundation
import UIKit

struct MessageTextCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageTextViewData) -> MessageTextLayout {
        
        var infoFrame: CGRect = .zero
        var syncIconFrame: CGRect? = .zero
        
        let size = data.message.sizeForLabel(width: targetSize.width, maxLines: 0)
        
        return MessageTextLayout(
            size: size,
            textFrame: CGRect(origin: .zero, size: size),
            infoFrame: infoFrame,
            syncIconFrame: syncIconFrame
        )
    }
    
}
