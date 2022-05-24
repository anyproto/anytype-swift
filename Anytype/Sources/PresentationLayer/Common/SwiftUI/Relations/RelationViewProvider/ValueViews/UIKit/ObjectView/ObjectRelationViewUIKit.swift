import UIKit

final class ObjectRelationViewUIKit: UIView {
    
    private let iconView = ObjectIconImageView()
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
        let icon = option.icon
        guard shouldShowIcon(icon: icon) else { return }
        
        let model = ObjectIconImageModel(
            iconImage: icon,
            usecase: .featuredRelationsBlock
        )
        
        iconView.configure(model: model)
    }
    
    func setupTitleLabel() {
        titleLabel = AnytypeLabel(style: relationStyle.font)
        titleLabel.setText(option.title)
        titleLabel.textColor = titleColor(option: option)
        titleLabel.setLineBreakMode(.byTruncatingTail)
    }
    
    func setupLayout() {
        if shouldShowIcon(icon: option.icon) {
            setupLayoutWithIcon()
        } else {
            setupLayoutWithoutIcon()
        }
    }
    
    func setupLayoutWithIcon() {
        layoutUsing.stack {
            $0.hStack(
                iconView,
                $0.hGap(fixed: relationStyle.objectRelationStyle.hSpaсingObject),
                titleLabel
            )
        }
        
        iconView.layoutUsing.anchors {
            $0.size(relationStyle.objectRelationStyle.size)
        }
    }
    
    func setupLayoutWithoutIcon() {
        layoutUsing.stack {
            $0.hStack(titleLabel)
        }
    }
    
}

private extension ObjectRelationViewUIKit {
    
    func titleColor(option: Relation.Object.Option) -> UIColor {
        if option.isDeleted || option.isArchived {
            return .textTertiary
        } else {
            return relationStyle.uiKitFontColor
        }
    }
    
    func shouldShowIcon(icon: ObjectIconImage) -> Bool {
        guard case .placeholder = icon else { return true }
        return false
    }
    
}
