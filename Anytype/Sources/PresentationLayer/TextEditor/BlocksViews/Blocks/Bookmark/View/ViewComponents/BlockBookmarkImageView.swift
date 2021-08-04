import UIKit
import Combine
import Kingfisher

class BlockBookmarkImageView: UIImageView {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        contentMode = .center
        clipsToBounds = true
        backgroundColor = .backgroundPrimary
    }
    
    
    func update(imageId: String) {
        let placeholder = PlaceholderImageBuilder.placeholder(
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
