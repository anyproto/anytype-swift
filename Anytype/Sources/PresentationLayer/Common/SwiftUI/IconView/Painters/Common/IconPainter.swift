import Foundation
import CoreGraphics

struct IconContext {
    let isEnabled: Bool
}

protocol IconPainter: AnyObject {
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext)
    func prepare(bounds: CGRect) async
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext)
}
