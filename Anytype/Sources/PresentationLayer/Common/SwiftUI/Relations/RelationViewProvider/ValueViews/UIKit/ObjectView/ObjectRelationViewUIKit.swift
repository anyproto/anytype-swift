import UIKit
import AnytypeCore

final class ObjectRelationViewUIKit: UIView {
    
    private let iconView = IconViewUIKit()
    private var titleLabel: AnytypeLabel!

    private let option: Relation.Object.Option
    private let relationStyle: RelationStyle
    
    init(options: Relation.Object.Option, relationStyle: RelationStyle) {
        self.option = options
        self.relationStyle = relationStyle

        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension ObjectRelationViewUIKit {
    
    func setupView() {
        setupIconViewIfNeeded()
        setupTitleLabel()

        setupLayout()
    }
    
    func setupIconViewIfNeeded() {
        guard let icon = option.icon else {
            iconView.isHidden = true
            return
        }
        
        iconView.icon = icon
        iconView.isHidden = false
    }
    
    func setupTitleLabel() {
        titleLabel = AnytypeLabel(style: relationStyle.font)
        titleLabel.setText(option.title)
        titleLabel.textColor = titleColor(option: option)
        titleLabel.setLineBreakMode(.byTruncatingTail)
    }
    
    func setupLayout() {
        layoutUsing.stack {
            $0.hStack(
                spacing: relationStyle.objectRelationStyle.hSpaсingObject,
                iconView,
                titleLabel
            )
        }
        
        iconView.layoutUsing.anchors {
            $0.size(relationStyle.objectRelationStyle.size)
        }
    }
    
}

private extension ObjectRelationViewUIKit {
    
    func titleColor(option: Relation.Object.Option) -> UIColor {
        if relationStyle.isError {
            return relationStyle.uiFontColorWithError
        } else if option.isDeleted || option.isArchived {
            return .Text.tertiary
        } else {
            return relationStyle.uiKitFontColor
        }
    }
}
