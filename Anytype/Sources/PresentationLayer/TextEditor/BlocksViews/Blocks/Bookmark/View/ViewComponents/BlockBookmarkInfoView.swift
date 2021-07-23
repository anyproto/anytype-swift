import UIKit
import Combine

final class BlockBookmarkInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func update(state: BlockBookmarkContentState) {
        updateIcon(state: state)
        removeAllSubviews()
        
        let stackView: UIStackView
        switch state {
        case let .onlyURL(url):
            urlView.text = url
            
            stackView = layoutUsing.stack {
                $0.vStack(urlStackView)
            }
        case let .fetched(payload):
            titleView.text = payload.title
            descriptionView.text = payload.subtitle
            urlView.text = payload.url
            
            stackView = layoutUsing.stack {
                $0.vStack(
                    titleView,
                    $0.vGap(fixed: 5),
                    descriptionView,
                    $0.vGap(min: 5),
                    urlStackView
                )
            }
        }
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 16)
    }
    
    private func updateIcon(state: BlockBookmarkContentState) {
        urlStackView.removeAllSubviews()
        guard case let .fetched(payload) = state, !payload.iconHash.isEmpty else {
            iconView.image = nil
            urlStackView.addSubview(urlView) {
                $0.pinToSuperview()
            }
            
            return
        }
        
        urlStackView.layoutUsing.stack {
            $0.hStack(
                iconView,
                $0.hGap(fixed: 6),
                urlView
            )
        }
        
        let placeholder = PlaceholderImageBuilder.placeholder(
            with: ImageGuideline(
                size: Layout.iconSize,
                cornerRadius: 4,
                backgroundColor: UIColor.grayscaleWhite
            ),
            color: UIColor.grayscale10
        )
        
        iconView.kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: payload.imageHash, width: .thumbnail)),
            placeholder: placeholder
        )
    }
    
    // MARK: - Views
    private var stackView = UIView()
    private var urlStackView = UIView()
    
    private let titleView: UILabel = {
        let view = UILabel()
        view.font = UIFont.captionMedium
        view.textColor = .grayscale90
        return view
    }()
    
    private let descriptionView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.font = .caption
        view.textColor = .grayscale70
        return view
    }()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: Layout.iconSize.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: Layout.iconSize.width).isActive = true
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

extension BlockBookmarkInfoView {
    enum Layout {
        static let iconSize = CGSize(width: 16, height: 16)
    }
}
