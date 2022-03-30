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
    
    func update(payload: BlockBookmarkPayload) {
        updateIcon(payload: payload)
        removeAllSubviews()
        
        titleView.text = payload.title
        descriptionView.text = payload.subtitle
        urlView.text = payload.url
        
        layoutUsing.stack {
            $0.edgesToSuperview(insets: Layout.contentInsets)
        } builder: {
            $0.vStack(
                titleView,
                $0.vGap(fixed: 2),
                descriptionView,
                $0.vGap(min: 4, max: 22),
                urlStackView
            )
        }
        
        titleView.layoutUsing.anchors {
            $0.bottom.equal(to: urlStackView.topAnchor, constant: -42)
        }
    }
    
    private func updateIcon(payload: BlockBookmarkPayload) {
        urlStackView.removeAllSubviews()
        
        guard !payload.faviconHash.isEmpty else {
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
        
        let imageGuideline = ImageGuideline(
            size: Layout.iconSize,
            radius: .point(2),
            backgroundColor: UIColor.backgroundPrimary
        )
        
        let placeholder = ImageBuilder(imageGuideline).build()
        
        let processor = KFProcessorBuilder(
            scalingType: .downsampling,
            targetSize: Layout.iconSize,
            cornerRadius: .point(2)
        ).processor
        
        iconView.wrapper
            .imageGuideline(imageGuideline)
            .setImage(id: payload.faviconHash)
//        iconView.kf.setImage(
//            with: ImageMetadata(
//                id: payload.faviconHash,
//                width: imageGuideline.size.width.asImageWidth
//            ).contentUrl,
//            placeholder: placeholder,
//            options: [.processor(processor), .transition(.fade(0.2))]
//        )

    }
    
    // MARK: - Views
    private var urlStackView: UIView = {
        let view = UIView()
        view.layoutUsing.anchors {
            $0.height.equal(to: 16)
        }
        return view
    }()
    
    private let titleView: UILabel = {
        let view = UILabel()
        view.font = .previewTitle2Regular
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.textColor = .textPrimary
        view.backgroundColor = .backgroundPrimary
        return view
    }()
    
    private let descriptionView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.font = .relation2Regular
        view.textColor = .textSecondary
        view.backgroundColor = .backgroundPrimary
        return view
    }()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = .backgroundPrimary
        view.layoutUsing.anchors {
            $0.size(Layout.iconSize)
        }
        return view
    }()
    
    private let urlView: UILabel = {
        let view = UILabel()
        view.font = .relation3Regular
        view.textColor = .textSecondary
        view.backgroundColor = .backgroundPrimary
        return view
    }()
}

extension BlockBookmarkInfoView {
    enum Layout {
        static let iconSize = CGSize(width: 16, height: 16)
        static let contentInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    }
}
