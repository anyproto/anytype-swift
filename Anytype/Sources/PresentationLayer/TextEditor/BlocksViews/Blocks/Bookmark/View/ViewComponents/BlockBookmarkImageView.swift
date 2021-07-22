import UIKit
import Combine

class BlockBookmarkImageView: UIImageView {
    private var imageSubscription: AnyCancellable?
    private var imageProperty: ImageProperty?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        contentMode = .center
        clipsToBounds = true
        backgroundColor = .white
    }
    
    
    func update(state: BlockBookmarkState) {
        guard case let .fetched(payload) = state, !payload.imageHash.isEmpty else {
            imageProperty = nil
            imageSubscription = nil
            self.image = nil
            
            return
        }
        
        imageProperty = ImageProperty(imageId: payload.iconHash, ImageParameters(width: .default))
        imageSubscription = imageProperty?.stream
            .receiveOnMain()
            .safelyUnwrapOptionals()
            .sink { [weak self] image in
                self?.image = image
            }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
