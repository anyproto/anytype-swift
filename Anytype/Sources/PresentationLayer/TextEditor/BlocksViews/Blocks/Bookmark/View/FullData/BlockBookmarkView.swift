import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView & UIContentView {
    private var currentConfiguration: BlockBookmarkConfiguration
    
    init(configuration: BlockBookmarkConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
        apply(payload: currentConfiguration.payload)
    }
    
    private func setup() {
        addSubview(bookmarkView) {
            $0.pinToSuperview(insets: Layout.bookmarkViewInsets)
            $0.height.equal(to: 108)
        }
    }
    
    private func apply(payload: BlockBookmarkPayload) {
        bookmarkView.removeAllSubviews()
        
        guard !payload.imageHash.isEmpty else {
            layoutWithoutImage(payload: payload)
            return
        }
        
        informationView.update(payload: payload)
        imageView.update(imageId: payload.imageHash)
        
        bookmarkView.addSubview(informationView) {
            $0.pinToSuperview(excluding: [.right])
        }
        
        bookmarkView.addSubview(imageView) {
            $0.height.equal(to: heightAnchor)
            $0.width.equal(to: widthAnchor, multiplier: Layout.imageSizeFactor)
            $0.leading.equal(to: informationView.trailingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
    
    private func layoutWithoutImage(payload: BlockBookmarkPayload) {
        informationView.update(payload: payload)
        bookmarkView.addSubview(informationView) {
            $0.pinToSuperview()
        }
    }

    // MARK: - Views
    private let informationView = BlockBookmarkInfoView()
    private let imageView = BlockBookmarkImageView()
    private let bookmarkView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayscale30.cgColor
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - UIContentView
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockBookmarkConfiguration,
                  configuration != currentConfiguration else { return }
            
            currentConfiguration = configuration
            apply(payload: currentConfiguration.payload)
        }
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("Not implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BlockBookmarkView {
    enum Layout {
        static let emptyViewHeight: CGFloat = 48
        static let bookmarkViewHeight: CGFloat = 108
        static let bookmarkViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
        static let imageSizeFactor: CGFloat = 1 / 3
        static let imageHeightConstant: CGFloat = 108
    }
}
