import Foundation
import UIKit

extension UIImage {
    
    func drawFit(in bounds: CGRect) {
        drawFit(in: bounds, maxSize: size)
    }
    
    func drawFit(in bounds: CGRect, maxSize: CGSize) {
        let multiple = maxSize.width > bounds.width ? bounds.width / maxSize.width : 1
        
        let imageBounds = CGRect(
            x: (bounds.maxX - maxSize.width * multiple) * 0.5,
            y: (bounds.maxY - maxSize.height * multiple) * 0.5,
            width: maxSize.width * multiple,
            height: maxSize.height * multiple
        )
        
        draw(in: imageBounds)
    }
    
    func drawFill(in bounds: CGRect) {
        drawFill(in: bounds, maxSize: size)
    }
    
    func drawFill(in bounds: CGRect, maxSize: CGSize) {
        let aspect = maxSize.width / maxSize.height
        let rect: CGRect
        if bounds.size.width / aspect > bounds.size.height {
            let height = bounds.size.width / aspect
            rect = CGRect(x: 0, y: (bounds.size.height - height) / 2,
                          width: bounds.size.width, height: height)
        } else {
            let width = bounds.size.height * aspect
            rect = CGRect(x: (bounds.size.width - width) / 2, y: 0,
                          width: width, height: bounds.size.height)
        }
        draw(in: rect)
    }
}
