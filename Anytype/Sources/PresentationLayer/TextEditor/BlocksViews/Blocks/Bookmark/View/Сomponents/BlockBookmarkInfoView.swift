import UIKit
import Combine
import Kingfisher
import AnytypeCore

final class BlockBookmarkInfoView: UIView {
    func update(payload: BlockBookmarkPayload) {
        updateIcon(payload: payload)
        removeAllSubviews()
        
        titleView.setText(payload.title)
        
        descriptionView.setText(payload.subtitle)
        descriptionView.isHidden = payload.subtitle.isEmpty
        
        urlView.setText(payload.source?.absoluteString ?? "")
        
        layoutUsing.stack {
            $0.edgesToSuperview()
        } builder: {
            $0.vStack(
                titleView,
                $0.vGap(fixed: 2, relatedTo: descriptionView),
                descriptionView,
                $0.vGap(fixed: 4),
                urlStackView
            )
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
    
    private let titleView: AnytypeLabel = {
        let view = AnytypeLabel(style: .previewTitle2Medium)
        view.numberOfLines = 2
        view.setLineBreakMode(.byWordWrapping)
        view.textColor = .Text.primary
        view.backgroundColor = .clear
        return view
    }()
    
    private let descriptionView: AnytypeLabel = {
        let view = AnytypeLabel(style: .relation3Regular)
        view.numberOfLines = 2
        view.setLineBreakMode(.byWordWrapping)
        view.textColor = .Text.primary
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
    
    private let urlView: AnytypeLabel = {
        let view = AnytypeLabel(style: .relation3Regular)
        view.textColor = .Text.secondary
        return view
    }()
}

extension BlockBookmarkInfoView {
    enum Layout {
        static let iconSize = CGSize(width: 16, height: 16)
    }
}
