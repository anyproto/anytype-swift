import SwiftUI
import AnytypeCore

final class AssetIconPainter: IconPainter {
    
    private let image: UIImage?
    let asset: ImageAsset
    
    init(asset: ImageAsset) {
        self.asset = asset
        self.image = UIImage(asset: asset)
    }
    
    // MARK: - IconPainter
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {}
    
    func prepare(bounds: CGRect) async {}
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        
        guard var image else { return }
        
        if image.renderingMode == .alwaysTemplate {
            image = image.withTintColor(iconContext.isEnabled ? .Button.active : .Button.inactive)
        }
        
        image.drawFit(in: bounds)
    }
}
