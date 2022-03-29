import UIKit
import Combine
import Kingfisher

class BlockBookmarkImageView: UIImageView {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFill
        
        clipsToBounds = true
        layer.cornerRadius = 2
        addDimmedOverlay(with: .black.withAlphaComponent(0.05))
        backgroundColor = .backgroundPrimary
        
        layoutUsing.anchors {
            $0.width.equal(to: 78)
            $0.height.equal(to: 78)
        }
    }
    
    
    func update(imageId: String) {
        let imageGuideline = ImageGuideline(
            size: bounds.size,
            backgroundColor: UIColor.backgroundPrimary
        )
        
        let placeholder = ImageBuilder(imageGuideline).build()
        
        kf.setImage(
            with: ImageMetadata(id: imageId, width: imageGuideline.size.width.asImageWidth).downloadingUrl,
            placeholder: placeholder
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
