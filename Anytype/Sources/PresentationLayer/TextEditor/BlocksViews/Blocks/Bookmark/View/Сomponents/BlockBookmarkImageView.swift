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
        let placeholder = ImageBuilder.placeholder(
            with: ImageGuideline(
                size: bounds.size,
                backgroundColor: UIColor.grayscaleWhite
            ),
            color: UIColor.grayscale10
        )
        
        kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: imageId, width: .default)),
            placeholder: placeholder
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
