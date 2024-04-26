import SwiftUI
import AnytypeCore

final class SmallImageIdPainter: IconPainter {
    
    let imageId: String
    private var image: UIImage?
    
    init(imageId: String) {
        self.imageId = imageId
    }
    
    // MARK: - IconPainter
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {}
    
    func prepare(bounds: CGRect) async {
        image = await AnytypeImageDownloader.retrieveImage(imageId: imageId, width: bounds.size.width)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        image?.drawFit(in: bounds, maxSize: CGSize(width: 24, height: 24))
    }
}
