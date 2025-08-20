import Foundation
import UIKit

struct MessageTextLayout: Equatable {
    let size: CGSize
    let textFrame: CGRect
}

struct MessageTextCalculator {
    
    static func calculateSize(targetSize: CGSize, message: NSAttributedString) -> MessageTextLayout {
        
        let size = message.sizeForLabel(width: targetSize.width, maxLines: 0)
        
        return MessageTextLayout(
            size: size,
            textFrame: CGRect(origin: .zero, size: size)
        )
    }
    
}
