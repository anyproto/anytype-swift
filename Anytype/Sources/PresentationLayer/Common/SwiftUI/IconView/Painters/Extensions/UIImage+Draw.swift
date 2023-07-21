import Foundation
import UIKit

extension UIImage {
    
    func drawFit(in bounds: CGRect) {
        drawFit(in: bounds, maxSize: size)
    }
    
    func drawFit(in bounds: CGRect, maxSize: CGSize) {
        let imageBounds = CGRect(
            x: (bounds.maxX - maxSize.width) * 0.5,
            y: (bounds.maxY - maxSize.height) * 0.5,
            width: maxSize.width,
            height: maxSize.height
        )
        
        draw(in: bounds.intersection(imageBounds))
    }
}
