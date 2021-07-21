import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView {
    private var informationView = BlockBookmarkInfoView()
    private var imageView: UIImageView!
    
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
        
        self.imageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        
        addSubview(informationView)
        addSubview(imageView)
        
        imageView.backgroundColor = .white
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
        if let view = self.imageView, let superview = view.superview {
            self.imageViewWidthConstraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: Layout.imageSizeFactor)
            self.imageViewWidthConstraint?.isActive = true
            
            self.imageViewHeightConstraint = view.heightAnchor.constraint(equalToConstant: Layout.imageHeightConstant)
            self.imageViewHeightConstraint?.isActive = true
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: informationView.trailingAnchor, constant: Layout.commonInsets.left),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
            ])
        }
    }
    
    func updateIcon(icon: UIImage) {
        informationView.updateIcon(icon: icon)
    }
    
    func updateImage(image: UIImage) {
        imageView.image = image
    }
    
    /// Configurations
    func handle(state: BlockBookmarkState) {
        informationView.update(state: state)
        
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

