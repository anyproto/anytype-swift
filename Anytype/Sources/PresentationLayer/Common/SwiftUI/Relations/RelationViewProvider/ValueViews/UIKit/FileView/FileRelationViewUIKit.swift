import UIKit

final class FileRelationViewUIKit: UIView {
    private let iconView = ObjectIconImageView()
    private var titleLabel: AnytypeLabel!

    private let option: RelationValue.File.Option
    private let relationStyle: RelationStyle
    
    init(options: RelationValue.File.Option, relationStyle: RelationStyle) {
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
        let model = ObjectIconImageModel(
            iconImage: option.icon,
            usecase: .featuredRelationsBlock
        )
        
        iconView.configure(model: model)
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
                iconView,
                $0.hGap(fixed: relationStyle.objectRelationStyle.hSpaсingObject),
                titleLabel
            )
        }
        
        iconView.layoutUsing.anchors {
            $0.size(relationStyle.objectRelationStyle.size)
        }
    }
    
}

