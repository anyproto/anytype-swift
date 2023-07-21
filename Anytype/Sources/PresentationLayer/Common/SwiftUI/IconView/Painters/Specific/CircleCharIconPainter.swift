import Foundation
import UIKit

final class CircleCharIconPainter: IconPainter {
    
    private let charPainter: IconPainter
    
    init(text: String) {
        self.charPainter = CharIconPainter(text: text)
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        charPainter.drawPlaceholder(bounds: bounds, context: context, iconContext: iconContext)
    }
    
    func prepare(bounds: CGRect) async {
        await charPainter.prepare(bounds: bounds)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        
        context.saveGState()
        
        let circlePath = CGPath(ellipseIn: bounds, transform: nil)
        context.addPath(circlePath)
        context.clip()
        
        context.setFillColor(UIColor.Stroke.secondary.cgColor)
        context.fill(bounds)

        charPainter.draw(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
}
