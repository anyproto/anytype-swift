import UIKit
import Combine
import Kingfisher
import AnytypeCore

final class BlockBookmarkInfoView: UIView {
    func update(payload: BlockBookmarkPayload) {
        updateIcon(payload: payload)
        removeAllSubviews()
        
        if FeatureFlags.redesignBookmarkBlock {
            titleView.setText(payload.title)
        } else {
            titleViewOld.text = payload.title
        }
        
        if FeatureFlags.redesignBookmarkBlock {
            descriptionView.setText(payload.subtitle)
        } else {
            descriptionViewOld.text = payload.subtitle
        }

        if FeatureFlags.redesignBookmarkBlock {
            urlView.setText(payload.source?.absoluteString ?? "")
        } else {
            urlViewOld.text = payload.source?.absoluteString
        }
        
        let titleView = FeatureFlags.redesignBookmarkBlock ? titleView : titleViewOld
        let descriptionView = FeatureFlags.redesignBookmarkBlock ? descriptionView : descriptionViewOld
        
        if FeatureFlags.redesignBookmarkBlock {
            layoutUsing.stack {
                $0.edgesToSuperview()
            } builder: {
                $0.vStack(
                    titleView,
                    $0.vGap(fixed: 2),
                    descriptionView,
                    $0.vGap(fixed: 4),
                    urlStackView
                )
            }
        } else {
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
        }
        
        
        titleView.layoutUsing.anchors {
            $0.bottom.equal(to: urlStackView.topAnchor, constant: -36)
        }
    }
    
    private func updateIcon(payload: BlockBookmarkPayload) {
        urlStackView.removeAllSubviews()
        
        let urlView = FeatureFlags.redesignBookmarkBlock ? urlView : urlViewOld
        
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
            backgroundColor: .clear
        )
        
        iconView.wrapper
            .imageGuideline(imageGuideline)
            .scalingType(.downsampling)
            .animatedTransition(false)
            .setImage(id: payload.faviconHash)
    }
    
    // MARK: - Views
    private var urlStackView: UIView = {
        let view = UIView()
        view.layoutUsing.anchors {
            $0.height.equal(to: 16)
        }
        return view
    }()
    
    private let titleViewOld: UILabel = {
        let view = UILabel()
        view.font = .previewTitle2Regular
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.textColor = .textPrimary
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleView: AnytypeLabel = {
        let view = AnytypeLabel(style: .previewTitle2Medium)
        view.numberOfLines = 2
        view.setLineBreakMode(.byWordWrapping)
        view.textColor = .textPrimary
        view.backgroundColor = .clear
        return view
    }()
    
    private let descriptionViewOld: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.font = .relation2Regular
        view.textColor = .textSecondary
        view.backgroundColor = .clear
        return view
    }()
    
    private let descriptionView: AnytypeLabel = {
        let view = AnytypeLabel(style: .relation3Regular)
        view.numberOfLines = 2
        view.setLineBreakMode(.byWordWrapping)
        view.textColor = .textPrimary
        view.backgroundColor = .clear
        return view
    }()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.layoutUsing.anchors {
            $0.size(Layout.iconSize)
        }
        return view
    }()
    
    private let urlViewOld: UILabel = {
        let view = UILabel()
        view.font = .relation3Regular
        view.textColor = .textSecondary
        view.backgroundColor = .clear
        return view
    }()
    
    private let urlView: AnytypeLabel = {
        let view = AnytypeLabel(style: .relation3Regular)
        view.textColor = .textSecondary
        return view
    }()
}

extension BlockBookmarkInfoView {
    enum Layout {
        static let iconSize = CGSize(width: 16, height: 16)
        // Delete with FeatureFlags.redesignBookmarkBlock
        static let contentInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    }
}
