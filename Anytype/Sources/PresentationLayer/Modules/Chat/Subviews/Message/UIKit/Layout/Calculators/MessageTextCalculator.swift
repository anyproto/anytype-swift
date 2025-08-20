import Foundation
import UIKit

struct MessageTextLayout: Equatable {
    let size: CGSize
    let textFrame: CGRect
}

struct MessageTextCalculator {
    
    static func calculateSize(targetSize: CGSize, message: NSAttributedString) -> MessageTextLayout {
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let textBounds = message.boundingRect(
            with: CGSize(width: targetSize.width, height: .greatestFiniteMagnitude),
            options: drawingOptions,
            context: nil
        )
        return MessageTextLayout(
            size: textBounds.size,
            textFrame: CGRect(origin: .zero, size: textBounds.size)
        )
    }
    
}
