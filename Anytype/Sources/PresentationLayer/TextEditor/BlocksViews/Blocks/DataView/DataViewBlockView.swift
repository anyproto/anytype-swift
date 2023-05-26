import Combine
import UIKit
import Services
import AnytypeCore

final class DataViewBlockView: UIView, BlockContentView {
    private let iconView = ObjectIconImageView()
    private let titleLabel: AnytypeLabel = {
        let title = AnytypeLabel(style: .subheading)
        title.numberOfLines = 1
        title.textColor = .Text.primary
        return title
    }()
    
    private let subtitleLabel: AnytypeLabel = {
        let subtitleLabel = AnytypeLabel(style: .relation3Regular)
        subtitleLabel.textColor = .Text.secondary
        return subtitleLabel
    }()
    
    private let badgeLabel: AnytypeLabel = {
        let label = AnytypeLabel(style: .caption2Regular)
        label.textColor = .Dark.grey
        label.textAlignment = .center
        return label
    }()
    
    private let badgeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .VeryLight.grey
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.dynamicBorderColor = .Stroke.primary
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: DataViewBlockConfiguration) {
        if let iconImage = configuration.content.iconImage {
            iconView.configure(
                model: ObjectIconImageModel(iconImage: iconImage, usecase: .editorCalloutBlock)
            )
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
        
        if let title = configuration.content.title, title.isNotEmpty {
            titleLabel.setText(title)
            titleLabel.textColor = .Text.primary
        } else {
            titleLabel.setText(configuration.content.placeholder)
            titleLabel.textColor = .Text.tertiary
        }
        if let badgeTitle = configuration.content.badgeTitle, badgeTitle.isNotEmpty {
            badgeLabel.setText(badgeTitle)
            badgeLabel.invalidateIntrinsicContentSize()
            badgeContainerView.isHidden = false
        } else {
            badgeContainerView.isHidden = true
        }
        
        subtitleLabel.setText(configuration.content.subtitle)
    }

    private func setup() {
        addSubview(contentView) {
            $0.pinToSuperview(insets: Layout.contentViewInsets)
        }
        
        badgeContainerView.addSubview(badgeLabel) {
            $0.pinToSuperview(insets: Layout.badgeLabelInsets)
        }
        
        contentView.layoutUsing.stack {
            $0.hStack(
                $0.hGap(fixed: Layout.contentInnerInsets.left),
                $0.vStack(
                    $0.vGap(fixed: Layout.contentInnerInsets.top),
                    $0.hStack(spacing: 6, alignedTo: .center,
                              iconView,
                              titleLabel,
                              badgeContainerView
                    ),
                    $0.vGap(fixed: 4),
                    subtitleLabel,
                    $0.vGap(fixed: Layout.contentInnerInsets.bottom)
                ),
                $0.hGap(fixed: Layout.contentInnerInsets.right)
            )
        }

        iconView.layoutUsing.anchors {
            $0.size(Layout.iconViewSize)
        }
    }
}

private extension DataViewBlockView {
    enum Layout {
        static let contentViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        static let badgeLabelInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        static let contentInnerInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let iconViewSize = CGSize(width: 20, height: 20)
    }
}
