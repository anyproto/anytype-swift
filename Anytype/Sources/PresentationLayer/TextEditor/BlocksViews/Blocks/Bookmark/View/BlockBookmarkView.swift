import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView {
    private let informationView = BlockBookmarkInfoView()
    private let imageView = BlockBookmarkImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func handle(state: BlockBookmarkState) {
        removeAllSubviews()
        
        guard case let .fetched(payload) = state, !payload.imageHash.isEmpty else {
            layoutWithoutImage(state: state)
            return
        }
        
        layoutWithImage(imageId: payload.imageHash, state: state)
    }
    
    private func layoutWithoutImage(state: BlockBookmarkState) {
        informationView.update(state: state)
        addSubview(informationView) {
            $0.pinToSuperview()
        }
    }
    
    private func layoutWithImage(imageId: BlockId, state: BlockBookmarkState) {
        informationView.update(state: state)
        imageView.update(imageId: imageId)
        
        addSubview(informationView) {
            $0.pinToSuperview(excluding: [.right])
        }
        
        addSubview(imageView) {
            $0.height.equal(to: heightAnchor)
            $0.width.equal(to: widthAnchor, multiplier: Layout.imageSizeFactor)
            $0.leading.equal(to: informationView.trailingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
}

private extension BlockBookmarkView {
    enum Layout {
        static let spacing: CGFloat = 5
        static let imageSizeFactor: CGFloat = 1 / 3
        static let imageHeightConstant: CGFloat = 108
    }
}
