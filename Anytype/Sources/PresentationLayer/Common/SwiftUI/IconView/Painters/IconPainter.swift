import Foundation
import CoreGraphics

struct IconContext: Hashable {
    let isEnabled: Bool
}

protocol IconPainter: AnyObject {
    @MainActor
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext)
    func prepare(bounds: CGRect) async
    @MainActor
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext)
}
