import UIKit
import Combine

final class BlockBookmarkInfoView: UIView {
    private var iconSubscription: AnyCancellable?
    private var iconProperty: ImageProperty?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func update(state: BlockBookmarkState) {
        updateIconSubscription(state: state)
        switch state {
        case let .onlyURL(url):
            urlView.text = url
            
            titleView.isHidden = true
            descriptionView.isHidden = true
            urlView.isHidden = false
            iconView.isHidden = true
            urlStackView.isHidden = false
        case let .fetched(payload):
            titleView.text = payload.title
            titleView.isHidden = false
            
            descriptionView.text = payload.subtitle
            descriptionView.isHidden = false
            urlView.text = payload.url
            urlView.isHidden = false
            iconView.isHidden = self.iconView.image == nil
            urlStackView.isHidden = false
        default:
            titleView.isHidden = true
            descriptionView.isHidden = true
            urlView.isHidden = true
            iconView.isHidden = true
            urlStackView.isHidden = true
        }
    }
    
    private func updateIconSubscription(state: BlockBookmarkState) {
        guard case let .fetched(payload) = state, !payload.iconHash.isEmpty else {
            iconProperty = nil
            iconSubscription = nil
            iconView.image = nil
            
            return
        }
        
        iconProperty = ImageProperty(imageId: payload.imageHash, .init(width: .thumbnail))
        iconSubscription = iconProperty?.stream
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sink { [weak self] icon in
                self?.iconView.image = icon
            }
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        
        urlStackView.addArrangedSubview(iconView)
        urlStackView.addArrangedSubview(urlView)
        
        let stack = layoutUsing.stack {
            $0.vStack(distributedTo: .fill,
                titleView,
                $0.vGap(fixed: 5),
                descriptionView,
                $0.vGap(min: 5),
                urlStackView
            )
        }
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 16)
        
    }
    
    // MARK: - Views
    private let titleView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.captionMedium
        view.textColor = .grayscale90
        return view
    }()
    
    private let descriptionView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 3
        view.lineBreakMode = .byWordWrapping
        view.font = .caption
        view.textColor = .grayscale70
        return view
    }()
    
    private let urlStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 24).isActive = true
        view.widthAnchor.constraint(equalToConstant: 24).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let urlView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .caption
        view.textColor = .grayscale90
        return view
    }()
}
