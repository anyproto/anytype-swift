import Foundation
import UIKit

struct MessageTextLayout: Equatable {
    let size: CGSize
    let textFrame: CGRect
}

struct MessageTextCalculator {
    
    static func calculateSize(targetSize: CGSize, message: NSAttributedString) -> MessageTextLayout {
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingBox = message.boundingRect(
            with: CGSize(width: targetSize.width, height: .greatestFiniteMagnitude),
            options: drawingOptions,
            context: nil
        )
        let size = CGSize(
            width: ceil(boundingBox.width),
            height: ceil(boundingBox.height)
        )
        return MessageTextLayout(
            size: size,
            textFrame: CGRect(origin: .zero, size: size)
        )
    }
    
}
