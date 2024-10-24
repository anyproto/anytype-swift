import UIKit
import Combine

class BlockBookmarkImageView: UIView {
    
    private let iconView = IconViewUIKit()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFill
        
        clipsToBounds = true
        layer.cornerRadius = 2
        
        addSubview(iconView) {
            $0.pinToSuperview()
        }
        
        let dimmedOverlayView = UIView()
        dimmedOverlayView.backgroundColor = .black.withAlphaComponent(0.05)
        
        addSubview(dimmedOverlayView)
        dimmedOverlayView.layoutUsing.anchors {
            $0.pinToSuperview()
        }
        
        backgroundColor = .Background.primary
        
        layoutUsing.anchors {
            $0.size(Constants.size)
        }
    }
    
    
    func update(imageId: String) {
        iconView.icon = .object(.bookmark(imageId))
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
