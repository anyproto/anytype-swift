import CoreText
import UIKit

extension NSAttributedString {
        
    func sizeForLabel(width: CGFloat, maxLines: Int = 0) -> CGSize {
        let constraintBox = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintBox,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        var height = ceil(boundingBox.height)
        
        let font = attributes(at: 0, effectiveRange: nil)[.font] as? UIFont
        
        if maxLines > 0, let font {
            let lineHeight = font.lineHeight
            let maxHeight = lineHeight * CGFloat(maxLines)
            height = min(height, maxHeight)
        }
        
        return CGSize(width: ceil(boundingBox.width), height: height)
    }
}
