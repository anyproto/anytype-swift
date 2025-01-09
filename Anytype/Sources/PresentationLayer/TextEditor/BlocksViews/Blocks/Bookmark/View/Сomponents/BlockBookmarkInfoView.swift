import UIKit
import Combine
import AnytypeCore

final class BlockBookmarkInfoView: UIView {
    func update(payload: BlockBookmarkPayload) {
        updateIcon(payload: payload)
        removeAllSubviews()
        
        titleView.setText(payload.title)
        
        descriptionView.setText(payload.subtitle)
        descriptionView.isHidden = payload.subtitle.isEmpty
        
        urlView.setText(payload.source?.url.host() ?? "")
        
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
        
        guard !payload.faviconObjectId.isEmpty else {
            iconView.icon = nil
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
        
        iconView.icon = .object(.bookmark(payload.faviconObjectId))
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
    
    private let iconView: IconViewUIKit = {
        let view = IconViewUIKit()
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
