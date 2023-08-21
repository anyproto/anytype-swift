import Foundation
import UIKit

final class SquareGradientIconPainter: IconPainter {
    
    private let painter: IconPainter
    
    init(gradientId: Int) {
        self.painter = GradientIdIconPainter(gradientId: gradientId)
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        painter.drawPlaceholder(bounds: bounds, context: context, iconContext: iconContext)
    }
    
    func prepare(bounds: CGRect) async {
        await painter.prepare(bounds: bounds)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        
        let side = min(bounds.size.width, bounds.size.height)
        
        context.saveGState()
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: side * (1/12)).cgPath
        context.addPath(path)
        context.clip()
        
        context.setFillColor(UIColor.Additional.space.cgColor)
        context.fill(bounds)
        
        let gradientBounds = bounds.insetBy(dx: side * (1/8), dy: side * (1/8))
        painter.draw(bounds: gradientBounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
}
