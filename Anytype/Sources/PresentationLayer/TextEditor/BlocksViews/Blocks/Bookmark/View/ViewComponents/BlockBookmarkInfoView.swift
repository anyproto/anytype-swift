import UIKit
import Combine
import Kingfisher

final class BlockBookmarkInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundPrimary
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
        
        guard case let .fetched(payload) = state, !payload.favIconHash.isEmpty else {
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
                cornerRadius: 2,
                backgroundColor: UIColor.grayscaleWhite
            ),
            color: UIColor.grayscale10
        )
        
        let processor = DownsamplingImageProcessor(size: Layout.iconSize)
        .append(another: RoundCornerImageProcessor(radius: .point(2)))
        
        iconView.kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: payload.favIconHash, width: .thumbnail)),
            placeholder: placeholder,
            options: [.processor(processor)]
        )
    }
    
    // MARK: - Views
    private var stackView = UIView()
    private var urlStackView = UIView()
    
    private let titleView: UILabel = {
        let view = UILabel()
        view.font = UIFont.captionMedium
        view.textColor = .grayscale90
        view.backgroundColor = .backgroundPrimary
        return view
    }()
    
    private let descriptionView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.font = .caption
        view.textColor = .grayscale70
        view.backgroundColor = .backgroundPrimary
        return view
    }()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
//        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.backgroundColor = .backgroundPrimary
        view.layoutUsing.anchors {
            $0.size(Layout.iconSize)
        }
        return view
    }()
    
    private let urlView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .caption
        view.textColor = .grayscale90
        view.backgroundColor = .backgroundPrimary
        return view
    }()
}

extension BlockBookmarkInfoView {
    enum Layout {
        static let iconSize = CGSize(width: 16, height: 16)
    }
}
