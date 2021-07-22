import UIKit
import Combine
import Kingfisher

class BlockBookmarkImageView: UIImageView {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        contentMode = .center
        clipsToBounds = true
        backgroundColor = .white
    }
    
    
    func update(imageId: String) {
        kf.setImage(with: UrlResolver.resolvedUrl(.image(id: imageId, width: .default)))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
