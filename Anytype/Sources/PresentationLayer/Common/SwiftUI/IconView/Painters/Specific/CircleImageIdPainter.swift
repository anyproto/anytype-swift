import Foundation
import UIKit

final class CircleImageIdPainter: IconPainter {
    
    private let painter: IconPainter
    
    init(imageId: String) {
        self.painter = ImageIdPainter(imageId: imageId)
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        painter.drawPlaceholder(bounds: bounds, context: context, iconContext: iconContext)
    }
    
    func prepare(bounds: CGRect) async {
        await painter.prepare(bounds: bounds)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        
        context.saveGState()
        
        let circlePath = CGPath(ellipseIn: bounds, transform: nil)
        context.addPath(circlePath)
        context.clip()
        
        painter.draw(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
}
