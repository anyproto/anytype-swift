import SwiftUI
import AnytypeCore

final class GradientIdIconPainter: IconPainter {
    
    private let storage = IconGradientStorage()
    let gradientId: Int
    
    init(gradientId: Int) {
        self.gradientId = gradientId
    }
    
    // MARK: - IconPainter
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {}
    
    func prepare(bounds: CGRect) async {}
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        let gradientInfo = storage.gradient(for: gradientId)
        
        let centerColor = gradientInfo.centerColor
        let roundColor = gradientInfo.roundColor
        let centerLocation = gradientInfo.centerLocation
        let roundLocation = gradientInfo.roundLocation

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [centerColor.cgColor, roundColor.cgColor] as CFArray,
            locations: [centerLocation, roundLocation]
        ) else {
            anytypeAssertionFailure("Gradient not created")
            return
        }

        let circlePath = CGPath(ellipseIn: bounds, transform: nil)
        context.addPath(circlePath)
        context.clip()

        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            startRadius: 0,
            endCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            endRadius: bounds.width * 0.51,
            options: []
        )
    }
}
