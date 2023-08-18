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
        backgroundColor = .Background.primary
        
        layoutUsing.anchors {
            $0.size(Constants.size)
        }
    }
    
    
    func update(imageId: String) {
        let imageGuideline = ImageGuideline(size: Constants.size, radius: .point(2))
        wrapper.imageGuideline(imageGuideline).setImage(id: imageId)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BlockBookmarkImageView {
    
    enum Constants {
        static let size = CGSize(width: 78, height: 78)
    }
    
}
