import Foundation
import UIKit

extension UIImage {
    
    func drawFit(in bounds: CGRect) {
        drawFit(in: bounds, maxSize: size)
    }
    
    func drawFit(in bounds: CGRect, maxSize: CGSize) {
        let multiple = maxSize.width > bounds.width ? 1 - (maxSize.width - bounds.width) / maxSize.width : 1
        
        let imageBounds = CGRect(
            x: (bounds.maxX - maxSize.width * multiple) * 0.5,
            y: (bounds.maxY - maxSize.height * multiple) * 0.5,
            width: maxSize.width * multiple,
            height: maxSize.height * multiple
        )
        
        draw(in: imageBounds)
    }
}
