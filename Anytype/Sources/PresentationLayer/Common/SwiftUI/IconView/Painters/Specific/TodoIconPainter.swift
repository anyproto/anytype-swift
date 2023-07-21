import Foundation
import UIKit

final class TodoIconPainter: IconPainter {
    
    private let checked: Bool
    
    init(checked: Bool) {
        self.checked = checked
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {}
    
    func prepare(bounds: CGRect) async {}
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        
        context.saveGState()
        
        var image = UIImage(asset: checked ? .TaskLayout.done : .TaskLayout.empty)
        
        if image?.renderingMode == .alwaysTemplate {
            image = image?.withTintColor(.Button.active)
        }
        
        image?.drawFit(in: bounds, maxSize: CGSize(width: 24, height: 24))
        
        context.restoreGState()
    }
}
