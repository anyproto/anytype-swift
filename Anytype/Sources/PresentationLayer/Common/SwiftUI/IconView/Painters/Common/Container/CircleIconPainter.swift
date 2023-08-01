import Foundation
import UIKit

final class CircleIconPainter: IconPainter {
    
    let contentPainter: IconPainter
    
    init(contentPainter: IconPainter) {
        self.contentPainter = contentPainter
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        contentPainter.drawPlaceholder(bounds: bounds, context: context, iconContext: iconContext)
    }
    
    func prepare(bounds: CGRect) async {
        await contentPainter.prepare(bounds: bounds)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        
        context.saveGState()
        
        let circlePath = CGPath(ellipseIn: bounds, transform: nil)
        context.addPath(circlePath)
        context.clip()
        
        context.setFillColor(UIColor.Stroke.secondary.cgColor)
        context.fill(bounds)

        contentPainter.draw(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
}
