import Foundation
import UIKit

final class SquareCharIconPainter: IconPainter {
    
    private let painter: IconPainter
    
    init(text: String) {
        self.painter = CharIconPainter(text: text)
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
        
        context.setFillColor(UIColor.Stroke.secondary.cgColor)
        context.fill(bounds)
        
        painter.draw(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
}
