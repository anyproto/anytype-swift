import SwiftUI

final class SquircleIconPainter: IconPainter {
    
    // MARK: - Private
    
    private struct Config {
        let side: CGFloat
        let cornerRadius: CGFloat?
        
        static let zero = Config(side: 0, cornerRadius: nil)
    }
    
    private static let configs = [
        Config(side: 16, cornerRadius: nil),
        Config(side: 18, cornerRadius: nil),
        Config(side: 20, cornerRadius: nil),
        Config(side: 40, cornerRadius: 8),
        Config(side: 48, cornerRadius: 10),
        Config(side: 64, cornerRadius: 14),
        Config(side: 80, cornerRadius: 18)
    ].sorted(by: { $0.side > $1.side }) // Order by DESK side for simple search
    
    private let contentPainter: IconPainter
    
    init(contentPainter: IconPainter) {
        self.contentPainter = contentPainter
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        context.saveGState()
        
        drawBackground(bounds: bounds, context: context, iconContext: iconContext)
        contentPainter.drawPlaceholder(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
    
    func prepare(bounds: CGRect) async {
        await contentPainter.prepare(bounds: bounds)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        context.saveGState()
        
        drawBackground(bounds: bounds, context: context, iconContext: iconContext)
        contentPainter.draw(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
    
    // MARK: - Private
    
    private func drawBackground(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        let side = min(bounds.size.width, bounds.size.height)
        let config = SquircleIconPainter.configs.first(where: { $0.side <= side }) ?? SquircleIconPainter.configs.last ?? .zero
        
        if let radius = config.cornerRadius {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
            context.addPath(path)
            context.clip()
            
            context.setFillColor(UIColor.Stroke.secondary.cgColor)
            context.fill(bounds)
        }
    }
}
