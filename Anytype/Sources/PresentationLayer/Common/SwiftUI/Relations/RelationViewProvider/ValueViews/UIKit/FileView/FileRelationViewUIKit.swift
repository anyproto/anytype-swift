import UIKit

final class FileRelationViewUIKit: UIView {
    private let iconView = IconViewUIKit()
    private var titleLabel: AnytypeLabel!

    private let option: Relation.File.Option
    private let relationStyle: RelationStyle
    
    init(options: Relation.File.Option, relationStyle: RelationStyle) {
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


private extension FileRelationViewUIKit {
    
    func setupView() {
        setupIconView()
        setupTitleLabel()

        setupLayout()
    }
    
    func setupIconView() {
        iconView.icon = option.icon
        iconView.isHidden = option.icon.isNil
    }
    
    func setupTitleLabel() {
        titleLabel = AnytypeLabel(style: relationStyle.font)
        titleLabel.setText(option.title)
        titleLabel.textColor = relationStyle.uiKitFontColor
        titleLabel.setLineBreakMode(.byTruncatingTail)
    }
    
    func setupLayout() {
        self.layoutUsing.stack {
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

