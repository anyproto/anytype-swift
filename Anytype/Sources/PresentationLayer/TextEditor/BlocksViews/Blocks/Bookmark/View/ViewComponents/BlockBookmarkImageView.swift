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
    
    
    func update(state: BlockBookmarkState) {
        guard case let .fetched(payload) = state, !payload.imageHash.isEmpty else {
            self.image = nil
            return
        }
        
        kf.setImage(with: UrlResolver.resolvedUrl(.image(id: payload.iconHash, width: .default)))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
