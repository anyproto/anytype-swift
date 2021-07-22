import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView {
    private var informationView = BlockBookmarkInfoView()
    private var imageView = BlockBookmarkImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIElements()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false        
        
        layoutUsing.stack {
            $0.hStack(
                informationView,
                $0.hGap(),
                imageView
            )
        }
        
        imageView.layoutUsing.anchors {
            $0.height.equal(to: Layout.imageHeightConstant)
            $0.width.equal(to: widthAnchor, multiplier: 0.3)
        }
    }
    
    func addLayoutForImageView() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: informationView.trailingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
            
            imageView.widthAnchor.constraint(
                equalTo: self.widthAnchor, multiplier: Layout.imageSizeFactor
            ),
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageHeightConstant)
        ])
    }
    
    func handle(state: BlockBookmarkState) {
        informationView.update(state: state)
        imageView.update(state: state)
        
        switch state {
        case let .fetched(payload):
            if !payload.imageHash.isEmpty {
                addLayoutForImageView()
                imageView.isHidden = false
            } else {
                imageView.removeFromSuperview()
                imageView.isHidden = true
            }
        default:
            break
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

