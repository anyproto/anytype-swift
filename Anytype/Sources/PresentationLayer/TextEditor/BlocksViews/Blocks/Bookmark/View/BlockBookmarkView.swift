import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView {
    private var informationView = BlockBookmarkInfoView()
    private var imageView = BlockBookmarkImageView()
    
    private var imageViewWidthConstraint: NSLayoutConstraint?
    private var imageViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIElements()
        addLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false        
        
        addSubview(informationView)
        addSubview(imageView)
    }
    
    /// Layout
    func addLayout() {
        NSLayoutConstraint.activate([
            informationView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Layout.commonInsets.left),
            informationView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -Layout.commonInsets.right),
            informationView.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.commonInsets.top),
            informationView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Layout.commonInsets.bottom)
        ])
    }
    
    func addLayoutForImageView() {
        imageViewWidthConstraint = imageView.widthAnchor.constraint(
            equalTo: self.widthAnchor, multiplier: Layout.imageSizeFactor
        )
        imageViewWidthConstraint?.isActive = true
        
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: Layout.imageHeightConstant)
        imageViewHeightConstraint?.isActive = true
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: informationView.trailingAnchor, constant: Layout.commonInsets.left
            ),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor)
        ])
    }
    
    func handle(state: BlockBookmarkState) {
        informationView.update(state: state)
        imageView.update(state: state)
        
        switch state {
        case let .fetched(payload):
            if !payload.imageHash.isEmpty {
                addLayoutForImageView()   
            }
        default:
            break
        }
    }
}

private extension BlockBookmarkView {
    enum Layout {
        static let commonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        static let spacing: CGFloat = 5
        static let imageSizeFactor: CGFloat = 1 / 3
        static let imageHeightConstant: CGFloat = 150
    }
}

