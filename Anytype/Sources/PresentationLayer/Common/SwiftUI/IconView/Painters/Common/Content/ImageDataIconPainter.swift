import SwiftUI
import AnytypeCore

final class ImageDataIconPainter: IconPainter {
    
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    // MARK: - IconPainter
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {}
    
    func prepare(bounds: CGRect) async {}
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        image.imageAsset?.image(with: UITraitCollection.current).drawFit(in: bounds)
    }
}
